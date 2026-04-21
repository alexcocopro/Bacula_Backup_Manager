#!/usr/bin/env bash
#
# Secure Backup Manager
# Backups de directorios y bases de datos con systemd timers, SSH keys,
# hashes SHA256, logs, notificaciones por email y restauracion.

set -Eeuo pipefail
IFS=$'\n\t'

VERSION="1.0.0"
APP_NAME="secure-backup-manager"
CONFIG_DIR="/etc/${APP_NAME}"
JOBS_DIR="${CONFIG_DIR}/jobs"
STATE_DIR="${CONFIG_DIR}/state"
KEY_DIR="${CONFIG_DIR}/ssh"
LOG_DIR="/var/log/${APP_NAME}"
DEFAULT_BACKUP_ROOT="/var/backups/${APP_NAME}"
RUN_DIR="/run/${APP_NAME}"
SCRIPT_INSTALL_PATH="/usr/local/sbin/${APP_NAME}"

if [[ -t 1 ]]; then
    C_RESET=$'\033[0m'
    C_RED=$'\033[0;31m'
    C_GREEN=$'\033[0;32m'
    C_YELLOW=$'\033[1;33m'
    C_BLUE=$'\033[0;34m'
    C_CYAN=$'\033[0;36m'
    C_BOLD=$'\033[1m'
else
    C_RESET=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_CYAN=""; C_BOLD=""
fi

CURRENT_LOG=""
STOPPED_SERVICES=()

info() { echo -e "${C_CYAN}[*]${C_RESET} $*"; log "INFO" "$*"; }
ok() { echo -e "${C_GREEN}[+]${C_RESET} $*"; log "INFO" "$*"; }
warn() { echo -e "${C_YELLOW}[!]${C_RESET} $*"; log "WARN" "$*"; }
fail() { echo -e "${C_RED}[x]${C_RESET} $*" >&2; log "ERROR" "$*"; }
die() { fail "$*"; exit 1; }

log() {
    local level="${1:-INFO}"
    local msg="${2:-}"
    [[ -n "${CURRENT_LOG:-}" ]] || return 0
    mkdir -p "$(dirname "$CURRENT_LOG")" 2>/dev/null || true
    printf '%s [%s] %s\n' "$(date -Is)" "$level" "$msg" >> "$CURRENT_LOG" 2>/dev/null || true
}

usage() {
    cat <<EOF
${APP_NAME} v${VERSION}

Uso:
  sudo ./${APP_NAME}.sh install
  sudo ./${APP_NAME}.sh configure
  sudo ./${APP_NAME}.sh run JOB_ID full|incremental
  sudo ./${APP_NAME}.sh status [JOB_ID]
  sudo ./${APP_NAME}.sh list [JOB_ID]
  sudo ./${APP_NAME}.sh verify JOB_ID BACKUP_ID
  sudo ./${APP_NAME}.sh restore JOB_ID BACKUP_ID /ruta/destino
  sudo ./${APP_NAME}.sh remote-key JOB_ID
  sudo ./${APP_NAME}.sh menu

Ejemplos de calendario systemd:
  Diario 02:00:        *-*-* 02:00:00
  Domingo 02:00:       Sun *-*-* 02:00:00
  Lunes a sabado 02:00 Mon..Sat *-*-* 02:00:00
EOF
}

require_root() {
    [[ "${EUID:-$(id -u)}" -eq 0 ]] || die "Ejecute como root: sudo $0 $*"
}

ensure_base_dirs() {
    mkdir -p "$CONFIG_DIR" "$JOBS_DIR" "$STATE_DIR" "$KEY_DIR" "$LOG_DIR" "$DEFAULT_BACKUP_ROOT" "$RUN_DIR"
    chmod 700 "$CONFIG_DIR" "$JOBS_DIR" "$STATE_DIR" "$KEY_DIR"
    chmod 750 "$LOG_DIR" "$DEFAULT_BACKUP_ROOT" "$RUN_DIR"
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1
}

detect_pkg_manager() {
    if need_cmd apt-get; then echo apt
    elif need_cmd dnf; then echo dnf
    elif need_cmd yum; then echo yum
    elif need_cmd zypper; then echo zypper
    elif need_cmd pacman; then echo pacman
    else echo unknown
    fi
}

install_packages() {
    local missing=()
    local cmd
    for cmd in tar gzip sha256sum rsync ssh systemctl flock find awk sed date; do
        need_cmd "$cmd" || missing+=("$cmd")
    done

    [[ ${#missing[@]} -eq 0 ]] && return 0

    warn "Faltan comandos requeridos: ${missing[*]}"
    local pm
    pm=$(detect_pkg_manager)

    case "$pm" in
        apt)
            apt-get update
            apt-get install -y tar gzip coreutils rsync openssh-client systemd util-linux findutils gawk sed mailutils
            ;;
        dnf) dnf install -y tar gzip coreutils rsync openssh-clients systemd util-linux findutils gawk sed mailx ;;
        yum) yum install -y tar gzip coreutils rsync openssh-clients systemd util-linux findutils gawk sed mailx ;;
        zypper) zypper install -y tar gzip coreutils rsync openssh-clients systemd util-linux findutils gawk sed mailx ;;
        pacman) pacman -Sy --noconfirm tar gzip coreutils rsync openssh systemd util-linux findutils gawk sed ;;
        *) die "No se detecto gestor de paquetes. Instale manualmente: tar gzip coreutils rsync openssh-client systemd util-linux" ;;
    esac
}

install_self() {
    require_root
    ensure_base_dirs
    install_packages

    local src
    src="$(readlink -f "$0")"
    install -m 750 "$src" "$SCRIPT_INSTALL_PATH"

    ok "Instalado en $SCRIPT_INSTALL_PATH"
    ok "Use: sudo ${APP_NAME} configure"
}

safe_job_id() {
    local raw="${1:-}"
    raw="${raw,,}"
    raw="${raw// /-}"
    raw="$(echo "$raw" | sed 's/[^a-z0-9._-]/-/g; s/--*/-/g; s/^-//; s/-$//')"
    [[ -n "$raw" ]] || raw="job-$(date +%Y%m%d%H%M%S)"
    echo "$raw"
}

shell_quote() {
    printf '%q' "$1"
}

write_var() {
    local file="$1"
    local key="$2"
    local value="${3:-}"
    printf '%s=%q\n' "$key" "$value" >> "$file"
}

load_job() {
    local job_id="${1:-}"
    [[ -n "$job_id" ]] || die "Falta JOB_ID"

    JOB_ID="$(safe_job_id "$job_id")"
    JOB_FILE="${JOBS_DIR}/${JOB_ID}.conf"
    [[ -f "$JOB_FILE" ]] || die "No existe el job: $JOB_ID"

    # shellcheck disable=SC1090
    source "$JOB_FILE"

    JOB_NAME="${JOB_NAME:-$JOB_ID}"
    BACKUP_ROOT="${BACKUP_ROOT:-${DEFAULT_BACKUP_ROOT}/${JOB_ID}}"
    DIRS_FILE="${DIRS_FILE:-${JOBS_DIR}/${JOB_ID}.dirs}"
    EXCLUDES_FILE="${EXCLUDES_FILE:-${JOBS_DIR}/${JOB_ID}.excludes}"
    SERVICES_FILE="${SERVICES_FILE:-${JOBS_DIR}/${JOB_ID}.services}"
    DB_NAMES_FILE="${DB_NAMES_FILE:-${JOBS_DIR}/${JOB_ID}.dbs}"
    RETENTION_DAYS="${RETENTION_DAYS:-30}"
    DB_TYPE="${DB_TYPE:-none}"
    DB_MODE="${DB_MODE:-logical}"
    REMOTE_ENABLED="${REMOTE_ENABLED:-false}"
    REMOTE_DEST="${REMOTE_DEST:-}"
    SSH_KEY="${SSH_KEY:-${KEY_DIR}/${JOB_ID}_ed25519}"
    SSH_PORT="${SSH_PORT:-22}"
    EMAIL_TO="${EMAIL_TO:-}"
    NOTIFY_SUCCESS="${NOTIFY_SUCCESS:-true}"
    NOTIFY_FAILURE="${NOTIFY_FAILURE:-true}"
    FULL_CALENDAR="${FULL_CALENDAR:-Sun *-*-* 02:00:00}"
    INCREMENTAL_CALENDAR="${INCREMENTAL_CALENDAR:-Mon..Sat *-*-* 02:00:00}"

    mkdir -p "$BACKUP_ROOT" "$STATE_DIR"
}

read_list() {
    local file="${1:-}"
    [[ -f "$file" ]] || return 0
    grep -Ev '^[[:space:]]*($|#)' "$file" || true
}

send_email() {
    local subject="$1"
    local body_file="$2"

    [[ -n "${EMAIL_TO:-}" ]] || return 0

    if need_cmd mail; then
        mail -s "$subject" "$EMAIL_TO" < "$body_file" || warn "No se pudo enviar email con mail"
    elif need_cmd mailx; then
        mailx -s "$subject" "$EMAIL_TO" < "$body_file" || warn "No se pudo enviar email con mailx"
    elif need_cmd sendmail; then
        {
            printf 'To: %s\n' "$EMAIL_TO"
            printf 'Subject: %s\n\n' "$subject"
            cat "$body_file"
        } | sendmail -t || warn "No se pudo enviar email con sendmail"
    else
        warn "No hay mail/mailx/sendmail instalado; se omite notificacion"
    fi
}

run_as_user() {
    local user="$1"
    shift

    if need_cmd runuser; then
        runuser -u "$user" -- "$@"
    elif need_cmd sudo; then
        sudo -u "$user" "$@"
    elif need_cmd su; then
        su - "$user" -c "$(printf '%q ' "$@")"
    else
        die "No existe runuser/sudo/su para ejecutar como $user"
    fi
}

notify_result() {
    local status="$1"
    local backup_id="${2:-}"
    local subject
    subject="[${APP_NAME}] ${status}: ${JOB_ID}"
    [[ -n "$backup_id" ]] && subject="${subject} ${backup_id}"

    case "$status" in
        SUCCESS) [[ "$NOTIFY_SUCCESS" == "true" ]] || return 0 ;;
        *) [[ "$NOTIFY_FAILURE" == "true" ]] || return 0 ;;
    esac

    send_email "$subject" "$CURRENT_LOG"
}

cleanup_services() {
    local svc
    if [[ ${#STOPPED_SERVICES[@]} -gt 0 ]]; then
        for (( idx=${#STOPPED_SERVICES[@]}-1 ; idx>=0 ; idx-- )); do
            svc="${STOPPED_SERVICES[$idx]}"
            log "INFO" "Starting service after backup: $svc"
            systemctl start "$svc" >> "$CURRENT_LOG" 2>&1 || log "ERROR" "Failed to start service: $svc"
        done
    fi
}

on_error() {
    local line="${1:-unknown}"
    fail "Error en linea $line. Revise log: ${CURRENT_LOG:-sin log}"
    cleanup_services
    if [[ -n "${JOB_ID:-}" && -n "${CURRENT_LOG:-}" ]]; then
        notify_result "FAILED" "${BACKUP_ID:-}"
    fi
}

stop_configured_services() {
    local svc
    while IFS= read -r svc; do
        [[ -n "$svc" ]] || continue
        if systemctl is-active --quiet "$svc"; then
            info "Deteniendo servicio: $svc"
            systemctl stop "$svc" >> "$CURRENT_LOG" 2>&1
            STOPPED_SERVICES+=("$svc")
        else
            log "INFO" "Service already stopped or inactive: $svc"
        fi
    done < <(read_list "$SERVICES_FILE")
}

create_db_dumps() {
    local dump_dir="$1"
    mkdir -p "$dump_dir"

    case "$DB_TYPE" in
        none|"") return 0 ;;
        postgres|postgresql)
            need_cmd pg_dumpall || die "pg_dumpall no esta instalado"
            if [[ -s "$DB_NAMES_FILE" ]]; then
                need_cmd pg_dump || die "pg_dump no esta instalado"
                local db
                while IFS= read -r db; do
                    [[ -n "$db" ]] || continue
                    info "Dump PostgreSQL: $db"
                    run_as_user postgres pg_dump -Fc "$db" > "${dump_dir}/postgres-${db}.dump"
                done < <(read_list "$DB_NAMES_FILE")
            else
                info "Dump PostgreSQL completo"
                run_as_user postgres pg_dumpall > "${dump_dir}/postgres-all.sql"
            fi
            ;;
        mysql|mariadb)
            need_cmd mysqldump || die "mysqldump no esta instalado"
            info "Dump MySQL/MariaDB completo"
            mysqldump --single-transaction --routines --events --all-databases > "${dump_dir}/mysql-all.sql"
            ;;
        *)
            die "DB_TYPE no soportado: $DB_TYPE"
            ;;
    esac
}

prepare_tar_file_list() {
    local file_list="$1"
    local dump_dir="$2"

    : > "$file_list"
    if [[ -f "$DIRS_FILE" ]]; then
        while IFS= read -r path; do
            [[ -n "$path" ]] || continue
            [[ -e "$path" ]] || { warn "Ruta no existe y se omitira: $path"; continue; }
            printf '%s\n' "$path" >> "$file_list"
        done < <(read_list "$DIRS_FILE")
    fi

    if [[ ! -s "$file_list" ]] && ! { [[ -d "$dump_dir" ]] && find "$dump_dir" -type f -print -quit | grep -q .; }; then
        die "No hay directorios ni dumps para respaldar"
    fi
}

make_manifest() {
    local manifest="$1"
    local backup_type="$2"
    local backup_id="$3"
    local chain_id="$4"
    local archive="$5"

    : > "$manifest"
    write_var "$manifest" APP_NAME "$APP_NAME"
    write_var "$manifest" VERSION "$VERSION"
    write_var "$manifest" JOB_ID "$JOB_ID"
    write_var "$manifest" JOB_NAME "$JOB_NAME"
    write_var "$manifest" BACKUP_ID "$backup_id"
    write_var "$manifest" BACKUP_TYPE "$backup_type"
    write_var "$manifest" CHAIN_ID "$chain_id"
    write_var "$manifest" HOSTNAME "$(hostname -f 2>/dev/null || hostname)"
    write_var "$manifest" CREATED_AT "$(date -Is)"
    write_var "$manifest" ARCHIVE "$(basename "$archive")"
    write_var "$manifest" SHA256_FILE "$(basename "$archive").sha256"
    write_var "$manifest" DB_TYPE "$DB_TYPE"
    write_var "$manifest" DB_MODE "$DB_MODE"
    write_var "$manifest" REMOTE_ENABLED "$REMOTE_ENABLED"
}

remote_parts() {
    local dest="${REMOTE_DEST:-}"
    [[ "$dest" == *:* ]] || die "REMOTE_DEST debe tener formato user@host:/ruta"
    REMOTE_HOST="${dest%%:*}"
    REMOTE_PATH="${dest#*:}"
    [[ -n "$REMOTE_HOST" && -n "$REMOTE_PATH" ]] || die "REMOTE_DEST invalido"
}

sync_remote() {
    local backup_dir="$1"
    local archive="$2"
    local hash_file="$3"
    local manifest="$4"

    [[ "$REMOTE_ENABLED" == "true" ]] || return 0
    [[ -f "$SSH_KEY" ]] || die "No existe llave SSH: $SSH_KEY. Use: $0 remote-key $JOB_ID"
    remote_parts

    local remote_job_dir="${REMOTE_PATH%/}/${JOB_ID}"
    local ssh_base=(ssh -i "$SSH_KEY" -p "$SSH_PORT" -o BatchMode=yes -o StrictHostKeyChecking=accept-new "$REMOTE_HOST")
    local rsync_ssh="ssh -i $(shell_quote "$SSH_KEY") -p $(shell_quote "$SSH_PORT") -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

    info "Creando destino remoto: ${REMOTE_HOST}:${remote_job_dir}"
    "${ssh_base[@]}" "mkdir -p $(shell_quote "$remote_job_dir")"

    info "Enviando respaldo remoto con rsync"
    rsync -az --protect-args -e "$rsync_ssh" "$backup_dir/" "${REMOTE_HOST}:${remote_job_dir}/" >> "$CURRENT_LOG" 2>&1

    info "Verificando hash en remoto"
    "${ssh_base[@]}" "cd $(shell_quote "${remote_job_dir}/$(basename "$backup_dir")") && sha256sum -c $(shell_quote "$(basename "$hash_file")")" >> "$CURRENT_LOG" 2>&1

    ok "Respaldo remoto verificado"
}

prune_old_backups() {
    [[ "$RETENTION_DAYS" =~ ^[0-9]+$ ]] || return 0
    [[ "$RETENTION_DAYS" -gt 0 ]] || return 0
    [[ -d "$BACKUP_ROOT" && "$BACKUP_ROOT" == "$DEFAULT_BACKUP_ROOT"* ]] || return 0

    info "Aplicando retencion local: ${RETENTION_DAYS} dias"
    find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" -name '20*' -exec rm -rf {} + >> "$CURRENT_LOG" 2>&1 || true
}

run_backup() {
    require_root
    local job_id="${1:-}"
    local requested_type="${2:-incremental}"
    load_job "$job_id"

    ensure_base_dirs
    mkdir -p "$BACKUP_ROOT" "$LOG_DIR" "$RUN_DIR"

    BACKUP_ID="$(date +%Y%m%d-%H%M%S)-${requested_type}"
    CURRENT_LOG="${LOG_DIR}/${JOB_ID}-${BACKUP_ID}.log"
    : > "$CURRENT_LOG"
    chmod 640 "$CURRENT_LOG"

    trap 'on_error $LINENO' ERR
    trap cleanup_services EXIT

    exec 9>"${RUN_DIR}/${JOB_ID}.lock"
    flock -n 9 || die "Ya hay un respaldo ejecutandose para $JOB_ID"

    local snapshot="${STATE_DIR}/${JOB_ID}.snar"
    local chain_file="${STATE_DIR}/${JOB_ID}.chain"
    local backup_type="$requested_type"

    if [[ "$backup_type" != "full" && "$backup_type" != "incremental" ]]; then
        die "Tipo invalido: $backup_type. Use full o incremental"
    fi

    if [[ "$backup_type" == "incremental" && ! -f "$snapshot" ]]; then
        warn "No existe base incremental previa; se ejecutara full"
        backup_type="full"
        BACKUP_ID="${BACKUP_ID/incremental/full}"
    fi

    local chain_id
    if [[ "$backup_type" == "full" ]]; then
        rm -f "$snapshot"
        chain_id="${BACKUP_ID}"
        echo "$chain_id" > "$chain_file"
    else
        chain_id="$(cat "$chain_file" 2>/dev/null || true)"
        [[ -n "$chain_id" ]] || die "No existe cadena full para incremental"
    fi

    local backup_dir="${BACKUP_ROOT}/${BACKUP_ID}"
    local work_dir="${backup_dir}/work"
    local dump_dir="${work_dir}/_db_dumps"
    local file_list="${work_dir}/files.list"
    local archive="${backup_dir}/${JOB_ID}-${BACKUP_ID}.tar.gz"
    local manifest="${backup_dir}/manifest.conf"
    local hash_file="${archive}.sha256"

    mkdir -p "$work_dir"
    chmod 700 "$backup_dir" "$work_dir"

    info "Iniciando respaldo $backup_type para $JOB_ID"

    if [[ "$DB_MODE" == "logical" ]]; then
        create_db_dumps "$dump_dir"
    elif [[ "$DB_MODE" != "cold" && "$DB_TYPE" != "none" ]]; then
        die "DB_MODE invalido: $DB_MODE"
    fi

    stop_configured_services

    if [[ "$DB_MODE" == "cold" ]]; then
        info "Modo cold: se respaldan los archivos configurados con servicios detenidos"
    fi

    prepare_tar_file_list "$file_list" "$dump_dir"

    info "Creando archivo tar.gz"
    local tar_args=(--create --gzip --listed-incremental="$snapshot" --file="$archive")
    if [[ -s "$EXCLUDES_FILE" ]]; then
        tar_args+=(--exclude-from="$EXCLUDES_FILE")
    fi
    if [[ -s "$file_list" ]]; then
        tar_args+=(--files-from="$file_list")
    fi
    if [[ -d "$dump_dir" ]] && find "$dump_dir" -type f -print -quit | grep -q .; then
        tar_args+=(-C "$work_dir" "_db_dumps")
    fi
    tar "${tar_args[@]}" >> "$CURRENT_LOG" 2>&1

    info "Generando hash SHA256"
    (cd "$backup_dir" && sha256sum "$(basename "$archive")" > "$(basename "$hash_file")")

    make_manifest "$manifest" "$backup_type" "$BACKUP_ID" "$chain_id" "$archive"
    rm -rf "$work_dir"

    info "Verificando integridad local"
    (cd "$backup_dir" && sha256sum -c "$(basename "$hash_file")") >> "$CURRENT_LOG" 2>&1

    sync_remote "$backup_dir" "$archive" "$hash_file" "$manifest"
    prune_old_backups

    ok "Respaldo completado: $backup_dir"
    notify_result "SUCCESS" "$BACKUP_ID"
}

list_jobs() {
    ensure_base_dirs
    local file
    shopt -s nullglob
    for file in "$JOBS_DIR"/*.conf; do
        basename "$file" .conf
    done
}

list_backups() {
    local job_id="${1:-}"
    if [[ -n "$job_id" ]]; then
        load_job "$job_id"
        find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort
    else
        local job
        while IFS= read -r job; do
            echo "== $job =="
            list_backups "$job" || true
        done < <(list_jobs)
    fi
}

verify_backup() {
    require_root
    local job_id="${1:-}"
    local backup_id="${2:-}"
    load_job "$job_id"
    [[ -n "$backup_id" ]] || die "Falta BACKUP_ID"

    local backup_dir="${BACKUP_ROOT}/${backup_id}"
    [[ -d "$backup_dir" ]] || die "No existe respaldo: $backup_dir"

    local hash_file
    hash_file="$(find "$backup_dir" -maxdepth 1 -name '*.sha256' -type f | head -1)"
    [[ -f "$hash_file" ]] || die "No existe hash SHA256 en $backup_dir"

    (cd "$backup_dir" && sha256sum -c "$(basename "$hash_file")")
}

restore_backup() {
    require_root
    local job_id="${1:-}"
    local backup_id="${2:-}"
    local restore_to="${3:-}"
    load_job "$job_id"

    [[ -n "$backup_id" ]] || die "Falta BACKUP_ID"
    [[ -n "$restore_to" ]] || die "Falta ruta destino de restauracion"

    local backup_dir="${BACKUP_ROOT}/${backup_id}"
    local manifest="${backup_dir}/manifest.conf"
    [[ -f "$manifest" ]] || die "No existe manifest: $manifest"

    verify_backup "$JOB_ID" "$backup_id"

    # shellcheck disable=SC1090
    source "$manifest"
    local target_chain="${CHAIN_ID:-$backup_id}"
    local restore_list=()
    local candidate c_manifest c_chain c_id

    while IFS= read -r candidate; do
        c_manifest="${BACKUP_ROOT}/${candidate}/manifest.conf"
        [[ -f "$c_manifest" ]] || continue
        c_chain="$(grep '^CHAIN_ID=' "$c_manifest" | cut -d= -f2-)"
        c_id="$(grep '^BACKUP_ID=' "$c_manifest" | cut -d= -f2-)"
        if [[ "$c_chain" == "$target_chain" ]] && { [[ "$c_id" < "${BACKUP_ID:-$backup_id}" ]] || [[ "$c_id" == "${BACKUP_ID:-$backup_id}" ]]; }; then
            restore_list+=("$candidate")
        fi
    done < <(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

    [[ ${#restore_list[@]} -gt 0 ]] || die "No se encontro cadena de restauracion"
    mkdir -p "$restore_to"

    CURRENT_LOG="${LOG_DIR}/${JOB_ID}-restore-$(date +%Y%m%d-%H%M%S).log"
    : > "$CURRENT_LOG"

    info "Restaurando en $restore_to"
    local item archive
    for item in "${restore_list[@]}"; do
        verify_backup "$JOB_ID" "$item" >> "$CURRENT_LOG" 2>&1
        archive="$(find "${BACKUP_ROOT}/${item}" -maxdepth 1 -name '*.tar.gz' -type f | head -1)"
        [[ -f "$archive" ]] || die "No existe archive para $item"
        info "Extrayendo $item"
        tar --extract --gzip --listed-incremental=/dev/null --file="$archive" --directory="$restore_to" >> "$CURRENT_LOG" 2>&1
    done

    ok "Restauracion completada en $restore_to"
    warn "Si el respaldo incluye dumps de base de datos, revise ${restore_to}/tmp o la ruta _db_dumps extraida y restaure manualmente con pg_restore/psql/mysql segun corresponda."
}

install_timers() {
    require_root
    local job_id="${1:-}"
    load_job "$job_id"

    local full_service="/etc/systemd/system/${APP_NAME}-${JOB_ID}-full.service"
    local full_timer="/etc/systemd/system/${APP_NAME}-${JOB_ID}-full.timer"
    local inc_service="/etc/systemd/system/${APP_NAME}-${JOB_ID}-incremental.service"
    local inc_timer="/etc/systemd/system/${APP_NAME}-${JOB_ID}-incremental.timer"
    local runner="$SCRIPT_INSTALL_PATH"

    [[ -x "$runner" ]] || runner="$(readlink -f "$0")"

    cat > "$full_service" <<EOF
[Unit]
Description=Full backup ${JOB_ID}
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=${runner} run ${JOB_ID} full
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=7
EOF

    cat > "$inc_service" <<EOF
[Unit]
Description=Incremental backup ${JOB_ID}
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=${runner} run ${JOB_ID} incremental
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=7
EOF

    cat > "$full_timer" <<EOF
[Unit]
Description=Timer full backup ${JOB_ID}

[Timer]
OnCalendar=${FULL_CALENDAR}
Persistent=true
RandomizedDelaySec=300
Unit=${APP_NAME}-${JOB_ID}-full.service

[Install]
WantedBy=timers.target
EOF

    cat > "$inc_timer" <<EOF
[Unit]
Description=Timer incremental backup ${JOB_ID}

[Timer]
OnCalendar=${INCREMENTAL_CALENDAR}
Persistent=true
RandomizedDelaySec=300
Unit=${APP_NAME}-${JOB_ID}-incremental.service

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now "${APP_NAME}-${JOB_ID}-full.timer" "${APP_NAME}-${JOB_ID}-incremental.timer"
    ok "Timers instalados y persistentes para $JOB_ID"
}

generate_ssh_key() {
    require_root
    local job_id="${1:-}"
    load_job "$job_id"

    if [[ ! -f "$SSH_KEY" ]]; then
        ssh-keygen -t ed25519 -a 100 -N "" -f "$SSH_KEY" -C "${APP_NAME}-${JOB_ID}@$(hostname -f 2>/dev/null || hostname)"
        chmod 600 "$SSH_KEY"
        chmod 644 "${SSH_KEY}.pub"
    fi

    ok "Llave privada: $SSH_KEY"
    echo ""
    echo "Instale esta llave publica en el equipo remoto dentro de ~/.ssh/authorized_keys:"
    echo ""
    cat "${SSH_KEY}.pub"
    echo ""
    if [[ -n "${REMOTE_DEST:-}" ]]; then
        remote_parts
        echo "Prueba manual:"
        echo "  ssh -i $SSH_KEY -p $SSH_PORT $REMOTE_HOST 'mkdir -p ${REMOTE_PATH%/}/${JOB_ID}'"
    fi
}

prompt() {
    local text="$1"
    local default="${2:-}"
    local value
    if [[ -n "$default" ]]; then
        read -r -p "$text [$default]: " value
        echo "${value:-$default}"
    else
        read -r -p "$text: " value
        echo "$value"
    fi
}

prompt_yes_no() {
    local text="$1"
    local default="${2:-n}"
    local value
    read -r -p "$text [$default]: " value
    value="${value:-$default}"
    [[ "$value" =~ ^[sSyY] ]]
}

configure_job() {
    require_root
    ensure_base_dirs

    echo -e "${C_BOLD}${C_BLUE}Secure Backup Manager - Nuevo job${C_RESET}"

    local name job_id backup_root retention full_cal inc_cal db_type db_mode remote_enabled remote_dest ssh_port email
    name="$(prompt "Nombre del job" "backup-principal")"
    job_id="$(safe_job_id "$name")"
    backup_root="$(prompt "Ruta local para guardar respaldos" "${DEFAULT_BACKUP_ROOT}/${job_id}")"
    retention="$(prompt "Retencion local en dias" "30")"

    local dirs_file="${JOBS_DIR}/${job_id}.dirs"
    local excludes_file="${JOBS_DIR}/${job_id}.excludes"
    local services_file="${JOBS_DIR}/${job_id}.services"
    local dbs_file="${JOBS_DIR}/${job_id}.dbs"
    : > "$dirs_file"; : > "$excludes_file"; : > "$services_file"; : > "$dbs_file"

    echo "Ingrese directorios a respaldar. Deje vacio para terminar."
    local path
    while true; do
        path="$(prompt "Directorio")"
        [[ -z "$path" ]] && break
        echo "$path" >> "$dirs_file"
    done

    echo "Ingrese patrones a excluir (opcional). Ej: *.tmp, cache, node_modules"
    while true; do
        path="$(prompt "Excluir")"
        [[ -z "$path" ]] && break
        echo "$path" >> "$excludes_file"
    done

    db_type="none"
    if prompt_yes_no "Desea respaldar base de datos? (s/n)" "n"; then
        db_type="$(prompt "Tipo DB: postgres/mysql" "postgres")"
        db_mode="$(prompt "Modo DB: logical para dump en caliente, cold para archivos con servicios detenidos" "logical")"
        if [[ "$db_mode" == "logical" && "$db_type" =~ ^postgres ]]; then
            echo "DB PostgreSQL especificas para pg_dump -Fc. Deje vacio para pg_dumpall."
            while true; do
                path="$(prompt "Base de datos")"
                [[ -z "$path" ]] && break
                echo "$path" >> "$dbs_file"
            done
        fi
    else
        db_mode="logical"
    fi

    echo "Servicios a detener durante el respaldo de archivos (opcional). Ej: postgresql, mysql, apache2"
    echo "Use esto para respaldos cold o sistemas que requieren consistencia por detencion."
    while true; do
        path="$(prompt "Servicio")"
        [[ -z "$path" ]] && break
        echo "$path" >> "$services_file"
    done

    full_cal="$(prompt "Calendario FULL systemd" "Sun *-*-* 02:00:00")"
    inc_cal="$(prompt "Calendario INCREMENTAL systemd" "Mon..Sat *-*-* 02:00:00")"

    remote_enabled="false"
    remote_dest=""
    ssh_port="22"
    if prompt_yes_no "Enviar respaldo a equipo remoto por SSH key? (s/n)" "n"; then
        remote_enabled="true"
        remote_dest="$(prompt "Destino remoto user@host:/ruta")"
        ssh_port="$(prompt "Puerto SSH" "22")"
    fi

    email="$(prompt "Email para notificaciones (opcional)")"

    local job_file="${JOBS_DIR}/${job_id}.conf"
    : > "$job_file"
    write_var "$job_file" JOB_ID "$job_id"
    write_var "$job_file" JOB_NAME "$name"
    write_var "$job_file" BACKUP_ROOT "$backup_root"
    write_var "$job_file" DIRS_FILE "$dirs_file"
    write_var "$job_file" EXCLUDES_FILE "$excludes_file"
    write_var "$job_file" SERVICES_FILE "$services_file"
    write_var "$job_file" DB_NAMES_FILE "$dbs_file"
    write_var "$job_file" RETENTION_DAYS "$retention"
    write_var "$job_file" DB_TYPE "$db_type"
    write_var "$job_file" DB_MODE "$db_mode"
    write_var "$job_file" REMOTE_ENABLED "$remote_enabled"
    write_var "$job_file" REMOTE_DEST "$remote_dest"
    write_var "$job_file" SSH_KEY "${KEY_DIR}/${job_id}_ed25519"
    write_var "$job_file" SSH_PORT "$ssh_port"
    write_var "$job_file" EMAIL_TO "$email"
    write_var "$job_file" NOTIFY_SUCCESS "true"
    write_var "$job_file" NOTIFY_FAILURE "true"
    write_var "$job_file" FULL_CALENDAR "$full_cal"
    write_var "$job_file" INCREMENTAL_CALENDAR "$inc_cal"
    chmod 600 "$job_file" "$dirs_file" "$excludes_file" "$services_file" "$dbs_file"
    mkdir -p "$backup_root"
    chmod 750 "$backup_root"

    ok "Job creado: $job_id"

    if [[ "$remote_enabled" == "true" ]]; then
        generate_ssh_key "$job_id"
    fi

    install_timers "$job_id"
}

show_status() {
    ensure_base_dirs
    local job_id="${1:-}"

    if [[ -z "$job_id" ]]; then
        echo "Jobs configurados:"
        list_jobs || true
        echo ""
        systemctl list-timers "${APP_NAME}-*.timer" --no-pager 2>/dev/null || true
        return 0
    fi

    load_job "$job_id"
    echo "Job: $JOB_ID"
    echo "Nombre: $JOB_NAME"
    echo "Local: $BACKUP_ROOT"
    echo "DB: $DB_TYPE ($DB_MODE)"
    echo "Remoto: $REMOTE_ENABLED ${REMOTE_DEST:-}"
    echo "Email: ${EMAIL_TO:-no configurado}"
    echo "Full: $FULL_CALENDAR"
    echo "Incremental: $INCREMENTAL_CALENDAR"
    echo ""
    systemctl status "${APP_NAME}-${JOB_ID}-full.timer" "${APP_NAME}-${JOB_ID}-incremental.timer" --no-pager 2>/dev/null || true
    echo ""
    echo "Ultimos respaldos:"
    list_backups "$JOB_ID" | tail -20 || true
}

menu() {
    while true; do
        echo ""
        echo -e "${C_BOLD}${APP_NAME}${C_RESET}"
        echo "1) Instalar dependencias y comando global"
        echo "2) Crear/configurar job"
        echo "3) Estado"
        echo "4) Ejecutar full ahora"
        echo "5) Ejecutar incremental ahora"
        echo "6) Listar respaldos"
        echo "7) Verificar respaldo"
        echo "8) Restaurar respaldo"
        echo "9) Mostrar llave SSH publica"
        echo "0) Salir"
        read -r -p "Opcion: " opt
        case "$opt" in
            1) install_self ;;
            2) configure_job ;;
            3) show_status "$(prompt "JOB_ID opcional")" ;;
            4) run_backup "$(prompt "JOB_ID")" full ;;
            5) run_backup "$(prompt "JOB_ID")" incremental ;;
            6) list_backups "$(prompt "JOB_ID opcional")" ;;
            7) verify_backup "$(prompt "JOB_ID")" "$(prompt "BACKUP_ID")" ;;
            8) restore_backup "$(prompt "JOB_ID")" "$(prompt "BACKUP_ID")" "$(prompt "Ruta destino")" ;;
            9) generate_ssh_key "$(prompt "JOB_ID")" ;;
            0) exit 0 ;;
            *) warn "Opcion invalida" ;;
        esac
    done
}

main() {
    local cmd="${1:-}"
    case "$cmd" in
        install) install_self ;;
        configure) configure_job ;;
        run) shift; run_backup "$@" ;;
        status) shift; show_status "${1:-}" ;;
        list) shift; list_backups "${1:-}" ;;
        verify) shift; verify_backup "$@" ;;
        restore) shift; restore_backup "$@" ;;
        timers) shift; install_timers "$@" ;;
        remote-key) shift; generate_ssh_key "$@" ;;
        menu|"") menu ;;
        help|-h|--help) usage ;;
        *) usage; exit 1 ;;
    esac
}

main "$@"
