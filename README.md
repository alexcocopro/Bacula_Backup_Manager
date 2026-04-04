# Bacula Backup Manager v2.1.1 - Enhanced Compatibility
# Gestor de Respaldo Bacula v2.1.1 - Compatibilidad Mejorada

<div align="center">

**Enterprise Backup Solution / Solución Empresarial de Respaldo**

[![Version](https://img.shields.io/badge/version-2.1.1-blue.svg)]()
[![License](https://img.shields.io/badge/license-GPL%20v3-green.svg)]()
[![Bash](https://img.shields.io/badge/bash-5.0%2B-green.svg)]()
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-9%2B-blue.svg)]()
[![Debian](https://img.shields.io/badge/Debian-9%2B-red.svg)]()
[![Ubuntu](https://img.shields.io/badge/Ubuntu-18.04%2B-orange.svg)]()

**Desarrollador:** Alex Cabello Leiva  
**Título:** Consultor en Innovación y Ciberseguridad

</div>

---

## 📋 Índice / Table of Contents

- [Descripción / Description](#-descripción--description)
- [Características / Features](#-características--features)
- [Requisitos / Requirements](#-requisitos--requirements)
- [Instalación / Installation](#-instalación--installation)
- [Uso / Usage](#-uso--usage)
- [Comando Baculamanager](#-comando-baculamanager)
- [Consultar Estado y Configuración](#-consultar-estado-y-configuración)
- [Respaldo Remoto](#-respaldo-remoto)
- [Logs y Monitoreo](#-logs-y-monitoreo)
- [Resetear Configuración](#-resetear-configuración)
- [Seguridad / Security](#-seguridad--security)
- [Compatibilidad PostgreSQL](#-compatibilidad-postgresql)
- [Compatibilidad de Sistemas](#-compatibilidad-de-sistemas)
- [Mapa de Ruta / Roadmap](#-mapa-de-ruta--roadmap)
- [Casos de Uso / Use Cases](#-casos-de-uso--use-cases)
- [Troubleshooting](#-troubleshooting)

---

## 📝 Descripción / Description

### Español
Sistema profesional de respaldos para Linux basado en **Bacula**, diseñado para ser **intuitivo, seguro y completamente bilingüe** (español/inglés). Instala y configura automáticamente todos los componentes necesarios, incluyendo **PostgreSQL como backend de catálogo**. Soporta **respaldos remotos** seguros vía SSH/LAN/VLAN. **Protege bases de datos PostgreSQL existentes (9+)** y evita conflictos en servidores de producción. **Compatible con Debian 9+ y Ubuntu 18.04+**.

### English
Professional Linux backup system based on **Bacula**, designed to be **intuitive, secure, and fully bilingual** (Spanish/English). Automatically installs and configures all necessary components, including **PostgreSQL as catalog backend**. Supports **secure remote backups** via SSH/LAN/VLAN. **Protects existing PostgreSQL databases (9+)** and avoids conflicts in production servers. **Compatible with Debian 9+ and Ubuntu 18.04+**.

---

## ✨ Características / Features

| Característica | Descripción |
|----------------|-------------|
| 🌐 **Bilingüe** | Interfaz completa en español e inglés / Full Spanish & English interface |
| 📦 **Instalación Automática** | Instala Bacula + PostgreSQL + todas las dependencias |
| 🎨 **Interfaz Amigable** | Menú interactivo con colores y explicaciones paso a paso |
| 🔒 **Seguridad Empresarial** | Contraseñas fuertes, permisos seguros, conexiones SSH |
| 🌐 **Respaldo Remoto** | SSH túnel, LAN/VLAN, VPN - con manejo seguro de credenciales |
| 🔑 **SSH Automático** | Generación y despliegue automático de claves SSH |
| 📊 **Estado y Logs** | Consulta integrada de configuración, estado y logs |
| 🔄 **Reset Configuración** | Menú para borrar y reiniciar configuraciones |
| ⚡ **Alto Rendimiento** | Compresión GZIP, respaldos incrementales, ejecución concurrente |
| 🕐 **Programación Flexible** | Diario, semanal, mensual o personalizado |
| 📟 **Comando Global** | Instala el comando `baculamanager` en el sistema |
| 🛡️ **Protección PostgreSQL** | Detecta y protege bases de datos existentes (9+) |
| 🔄 **Compatibilidad Inteligente** | Usa PostgreSQL existente o instala versión compatible |
| 🐧 **Debian 9+ Support** | Compatible con Stretch, Buster, Bullseye, Bookworm |
| 🔄 **Ubuntu 18.04+ Support** | Compatible con Bionic, Focal, Jammy, Noble |
| 🎯 **Detección Automática** | Detecta versión del SO y ajusta instalación |
| 🔄 **Múltiples Jobs Independientes** | Crear y gestionar múltiples respaldos con diferentes configuraciones |
| 📧 **Notificaciones por Email** | Alertas automáticas de éxito, fallos y limpieza por retención |
| 🔌 **Gestión Automática de Puertos** | Abre puertos solo durante backups, cierra automáticamente |
| 📋 **Políticas de Retención** | 30 días, 90 días, 1 año, o para siempre |
| 🗑️ **Limpieza Automática** | Eliminación de respaldos obsoletos según políticas configuradas |
| 📊 **Monitoreo Avanzado** | Estado detallado de todos los jobs y almacenamiento |
| 🛡️ **Seguridad de Firewall** | Configuración automática de iptables/ufw/firewalld |

---

## 🛠️ Requisitos / Requirements

### Sistemas Operativos Soportados

#### **Debian Family**
- **Debian 9** (Stretch) - PostgreSQL 9.6/10/11
- **Debian 10** (Buster) - PostgreSQL 11/12/13
- **Debian 11** (Bullseye) - PostgreSQL 13/14/15
- **Debian 12** (Bookworm) - PostgreSQL 15

#### **Ubuntu Family**
- **Ubuntu 18.04** (Bionic) - PostgreSQL 10/11/12
- **Ubuntu 20.04** (Focal) - PostgreSQL 12/13/14
- **Ubuntu 22.04** (Jammy) - PostgreSQL 14/15
- **Ubuntu 24.04** (Noble) - PostgreSQL 16

#### **RHEL Family**
- **RHEL 7** - PostgreSQL 9.6/10/12
- **RHEL 8** - PostgreSQL 10/12/13/15
- **RHEL 9** - PostgreSQL 13/15/16
- **CentOS 7** - PostgreSQL 9.6/10/12
- **CentOS 8/Stream** - PostgreSQL 10/12/13/15
- **Rocky Linux 8/9** - PostgreSQL 10/12/13/15/16
- **AlmaLinux 8/9** - PostgreSQL 10/12/13/15/16

### Requisitos Mínimos / Minimum Requirements
```
- CPU: 2 cores
- RAM: 4 GB
- Disco: 20 GB + espacio para respaldos
- Red: Conexión internet (instalación)
- Privilegios: Root / sudo
- Para remoto: Acceso SSH al host remoto
- PostgreSQL: 9+ (si existe) o instala versión compatible según SO
```

---

## 🚀 Instalación / Installation

### Requisitos Previos / Prerequisites

```bash
# Actualizar sistema
sudo apt-get update && sudo apt-get upgrade -y

# Instalar dependencias básicas (si no están presentes)
sudo apt-get install -y curl wget openssl

# Verificar que tienes privilegios de root
whoami  # Debe decir "root" o estar usando sudo
```

### Instalación Rápida / Quick Start

#### **Paso 1: Descargar el Script**

```bash
# Clonar o descargar el script
cd /tmp
git clone <repository-url>  # Si está en git
# O descargar directamente:
wget -O bacula_backup_manager.sh <url-del-script>
```

#### **Paso 2: Dar Permisos y Ejecutar**

```bash
# Dar permisos de ejecución
chmod +x bacula_backup_manager.sh

# Ejecutar como root (REQUERIDO)
sudo ./bacula_backup_manager.sh
```

#### **Paso 3: Seguir el Menú Interactivo**

1. **Seleccionar idioma** (Opción 1)
   - Español o Inglés

2. **Instalar Bacula** (Opción 2)
   - El script detectará automáticamente tu sistema
   - Instalará PostgreSQL si no existe
   - Configurará todos los componentes

3. **Crear un Job de Respaldo** (después de la instalación)
   - Seleccionar qué respaldar (Sistema completo, Home, Custom)
   - Definir horario (ej: 02:00 AM)
   - Establecer retención (30 días, 90 días, 1 año)

#### **Paso 4: Verificar Instalación**

```bash
# Verificar estado de servicios
sudo systemctl status postgresql bacula-dir bacula-sd bacula-fd

# Verificar configuración
sudo baculamanager --test

# Ver logs
sudo tail -f /var/log/bacula/bacula.log
```

---

### Flujo de Instalación Automática

Cuando ejecutas el script, el flujo automático es:

```
1. Detectar distribución Linux (Debian/Ubuntu/RHEL)
2. Verificar PostgreSQL existente
   ├── Si existe (v9+): Usarlo para Bacula
   └── Si no existe: Instalar PostgreSQL compatible
3. Instalar paquetes Bacula (director, storage, file daemon)
4. Crear base de datos 'bacula' y usuario 'bacula'
5. Generar configuraciones iniciales
6. Iniciar servicios
7. Crear comando 'baculamanager' global
```

---

### 1. Ejecutar el Script (Método Manual Detallado)

```bash
sudo chmod +x bacula_backup_manager.sh
sudo ./bacula_backup_manager.sh
```

El sistema automáticamente:
1. **Detecta PostgreSQL existente** y verifica compatibilidad
2. Protege bases de datos en producción
3. Detecta la distribución Linux
4. Instala Bacula Director, Storage y File Daemon
5. Usa PostgreSQL existente (9+) o instala versión compatible automáticamente
6. Crea el catálogo de base de datos
7. Configura permisos seguros
8. Inicia los servicios
9. **Instala el comando `baculamanager`** globalmente

### 2. Instalar comando baculamanager (opcional)

Para instalar el comando `baculamanager` en el sistema:
```bash
sudo ./bacula_backup_manager.sh --install-command
```

Esto permite ejecutar el gestor desde cualquier lugar:
```bash
sudo baculamanager
```

---

## Uso / Usage

### Menú Principal / Main Menu

```
╔═════════════════════════════════════════════════════════════════════════╗
║                           MENÚ PRINCIPAL 🇪🇸                                ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  Status: ✓ Installed | 🌐 Remote: 192.168.1.10 | 🐘 PostgreSQL: 15.x     ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  1) Instalar y Configurar Bacula    5) Reconfigurar Sistema               ║
║  2) Ejecutar Trabajo de Respaldo    6) Ver Logs                           ║
║  3) Restaurar desde Respaldo        7) Probar Configuración               ║
║  4) Ver Estado de Respaldos         8) Cambiar Idioma 🇺🇸                  ║
║                                                                           ║
║  Remote Backup Options:                                                   ║
║  9) Configuración de Respaldo Remoto  11) Probar Conectividad de Red   ║
║  10) Gestionar Claves SSH                                               ║
║                                                                           ║
║  Management Options:                                                   ║
║  12) Resetear Configuración   13) Ver Configuración Completa             ║
║  14) Email Notifications Status / Estado de Notificaciones               ║
║  15) Port Management / Gestión de Puertos                             ║
║                                                                           ║
║  0) Salir                                                                 ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## Comando Baculamanager

### Instalación del Comando

El script puede instalarse como un comando global del sistema:

```bash
sudo ./bacula_backup_manager.sh --install-command
```

Esto crea:
- `/usr/local/bin/baculamanager` - Enlace al script
- `/usr/local/bin/bacula-manager` - Alias alternativo

### Uso del Comando

```bash
# Ejecutar el menú principal
sudo baculamanager

# Ver configuración actual
sudo baculamanager --config

# Ver estado de los servicios
sudo baculamanager --status

# Ver logs recientes
sudo baculamanager --logs

# Verificar instalación
sudo baculamanager --check

# Ver ayuda
sudo baculamanager --help
```

---

## 🔍 Consultar Estado y Configuración

### Ver Estado de Funcionamiento (Opción 4 del menú)

Muestra información en tiempo real:
- ✅ Estado de servicios (bacula-dir, bacula-sd, bacula-fd)
- 📅 Último respaldo realizado
- 📆 Próximo respaldo programado
- 💾 Espacio utilizado en almacenamiento
- 🌐 Estado de conexión remota (si está configurada)
- 📊 Cola de trabajos pendientes
- 🐘 Estado de PostgreSQL

### Ver Configuración Completa (Opción 13 del menú)

Muestra toda la configuración actual:

```
═══════════════════════════════════════════════════════════════════════════
                        CONFIGURACIÓN COMPLETA
═══════════════════════════════════════════════════════════════════════════

Instalación:
  Bacula Instalado:     ✓ Sí
  Versión:              13.0.1
  Configurado:          ✓ Sí (2024-01-15 10:30:00)

Servicios:
  bacula-dir:           ✓ Running (PID: 1234)
  bacula-sd:            ✓ Running (PID: 1235)
  bacula-fd:            ✓ Running (PID: 1236)

PostgreSQL:
  Versión:              15.x (existente) / 15.x (instalado)
  Base Bacula:          ✓ Configurada
  Bases Existentes:      3 (production_db1, production_db2, app_db)
  Protección:            ✓ Activa

Configuración Local:
  Director Name:        director-backup
  Backup Path:          /backups/local
  Retención:            30 días
  Compresión:           GZIP nivel 6
  Tipo de respaldo:     Incremental

Configuración Remota:
  Respaldo remoto:      ✓ Habilitado
  Host remoto:          192.168.1.10
  Usuario:              root
  Tipo de conexión:     SSH Tunnel
  Ruta remota:          /backups/remote
  SSH Key:              bacula_remote
  Estado conexión:      ✓ Conectado

Almacenamiento:
  Espacio disponible:   45.2 GB
  Espacio usado:        12.8 GB
  Volumes totales:      15
```

---

## 🌐 Respaldo Remoto

### Configuración de Respaldo Remoto (Opción 9)

Permite configurar respaldos en hosts remotos de forma segura:

1. **Detección automática de red** - Identifica segmentos LAN/VLAN
2. **Generación de claves SSH** - Ed25519 o RSA-4096 automáticamente
3. **Despliegue de claves** - Usando sshpass o ssh-copy-id
4. **Túneles SSH automáticos** - Con auto-reconexión y monitoreo
5. **Credenciales seguras** - Almacenadas cifradas en base64

### Tipos de Conexión Soportados

| Tipo | Descripción | Caso de Uso |
|------|-------------|-------------|
| **SSH Tunnel** | Túnel seguro localhost→remoto | WAN / Internet / No confiable |
| **Direct** | Conexión directa Bacula | Misma LAN/VLAN confiable |
| **VPN** | A través de VPN establecida | Redes privadas virtuales |

### Gestionar Claves SSH (Opción 10)

Menú de gestión de claves:
- Generar nuevas claves SSH
- Desplegar clave a host remoto
- Probar conexión SSH

### Probar Conectividad de Red (Opción 11)

Tests de conectividad:
- Ping ICMP
- TCP port check (puerto 22 por defecto)
- Detección de segmentos de red
- Diagnóstico de firewalls y ACLs

---

## 📋 Logs y Monitoreo

### Ver Logs desde el Script (Opción 6)

El script permite consultar todos los logs desde el menú:

| Log | Ubicación | Descripción |
|-----|-----------|-------------|
| **Director Log** | `/var/log/bacula/bacula.log` | Eventos del Director Bacula |
| **Storage Log** | `/var/log/bacula/bacula-sd.log` | Eventos del Storage Daemon |
| **File Daemon** | `/var/log/bacula/bacula-fd.log` | Eventos del File Daemon |
| **Manager Log** | `/var/log/bacula-manager/` | Logs del gestor |

### Logs de Manager

Los logs del gestor incluyen:
- Instalaciones y configuraciones
- Respaldos ejecutados
- Errores y advertencias
- Conexiones SSH establecidas
- Cambios de configuración

```
/var/log/bacula-manager/
├── manager.log           # Log principal
├── install.log          # Log de instalación
├── backup.log           # Log de respaldos
└── remote.log           # Log de conexiones remotas
```

---

## �️ Resetear Configuración

### Resetear Configuración (Opción 12)

Permite borrar configuraciones de forma selectiva o completa:

```
¿Qué desea resetear?

1) Resetear configuración local de Bacula
2) Resetear configuración remota
3) Resetear claves SSH
4) Borrar todos los logs
5) Resetear COMPLETAMENTE TODO
6) Volver
```

### Opciones de Reset

| Opción | Descripción | Precaución |
|--------|-------------|------------|
| **Reset Local** | Borra `bacula-dir.conf`, `bacula-sd.conf`, `bacula-fd.conf` | Pérdida de configuración local |
| **Reset Remoto** | Borra configuración remota y túneles SSH | Desconexión de hosts remotos |
| **Reset SSH Keys** | Elimina todas las claves SSH del gestor | Requiere reconfiguración SSH |
| **Clear Logs** | Borra todos los logs del gestor | Pérdida de historial |
| **Reset Total** | Borra TODO y reinicia desde cero | **Pérdida total de configuración** |

---

## 📁 Estructura de Archivos / File Structure

```
/etc/bacula/
├── bacula-dir.conf              # Configuración del Director
├── bacula-sd.conf               # Configuración del Storage Daemon
├── bacula-fd.conf               # Configuración del File Daemon
├── bacula-sd-remote.conf        # Configuración de almacenamiento remoto
└── bconsole.conf                # Configuración de consola

/etc/bacula-manager/
├── manager.conf                 # Configuración del gestor
├── db_credentials.conf          # Credenciales PostgreSQL (600)
├── lang.conf                    # Preferencia de idioma
├── environment                  # Credenciales cifradas base64 (600)
└── remote/
    └── active.conf              # Configuración remota activa (600)

/usr/local/bin/
├── baculamanager                # Comando principal (enlace)
├── bacula-manager               # Alias alternativo (enlace)
└── bacula-ssh-tunnel.sh         # Script de túnel SSH automático

/var/lib/bacula/                 # Datos de trabajo
/var/log/bacula/                 # Logs de Bacula
/var/log/bacula-manager/         # Logs del gestor
/root/.ssh/
├── bacula_remote                # Clave SSH privada (600)
└── bacula_remote.pub            # Clave SSH pública (644)
```

---

## 🐘 Compatibilidad PostgreSQL

### Detección y Protección Automática

El script implementa **protección inteligente de PostgreSQL** para evitar conflictos en servidores de producción:

#### **Versiones Soportadas:**

| Versión PostgreSQL | Estado | Compatibilidad |
|-------------------|---------|----------------|
| **PostgreSQL 9.x** | ✅ Soportado | Compatible con Debian 9/10, RHEL 7 |
| **PostgreSQL 10.x** | ✅ Soportado | Compatible con Ubuntu 18.04, RHEL 7/8 |
| **PostgreSQL 11.x** | ✅ Soportado | Compatible con Debian 10, Ubuntu 18.04/20.04 |
| **PostgreSQL 12.x** | ✅ Soportado | Compatible con Debian 10/11, Ubuntu 20.04 |
| **PostgreSQL 13.x** | ✅ Soportado | Compatible con Debian 11, Ubuntu 22.04, RHEL 8/9 |
| **PostgreSQL 14.x** | ✅ Soportado | Compatible con Debian 11/12, Ubuntu 22.04/24.04 |
| **PostgreSQL 15.x** | ✅ Soportado | Compatible con Debian 11/12, Ubuntu 22.04/24.04 |
| **PostgreSQL 16.x** | ✅ Soportado | Compatible con Ubuntu 24.04, RHEL 9 |
| **PostgreSQL < 9.x** | ❌ No Soportado | Requiere actualización manual |

#### **Selección Automática por SO:**

**Debian:**
- **Debian 9** (Stretch): Instala PostgreSQL 11
- **Debian 10** (Buster): Instala PostgreSQL 11/13
- **Debian 11** (Bullseye): Instala PostgreSQL 13/15
- **Debian 12** (Bookworm): Instala PostgreSQL 15

**Ubuntu:**
- **Ubuntu 18.04** (Bionic): Instala PostgreSQL 10/12
- **Ubuntu 20.04** (Focal): Instala PostgreSQL 12/14
- **Ubuntu 22.04** (Jammy): Instala PostgreSQL 14/15
- **Ubuntu 24.04** (Noble): Instala PostgreSQL 16

**RHEL Family:**
- **RHEL/CentOS 7**: Usa PostgreSQL del repositorio (9.6/10/12)
- **RHEL/CentOS 8**: Usa PostgreSQL del repositorio (10/12/13/15)
- **RHEL/Rocky/AlmaLinux 9**: Usa PostgreSQL del repositorio (13/15/16)

#### **Flujo de Detección:**

1. **Verificación Previa**: Antes de instalar, detecta PostgreSQL existente
2. **Análisis de Versiones**: Compara versión instalada con requisitos (9+)
3. **Detección de Bases de Datos**: Identifica bases de datos en producción
4. **Confirmación Usuario**: Pide aprobación antes de proceder
5. **Selección Inteligente**: Elige mejor versión disponible para el SO

#### **Estrategias de Instalación:**

| Situación | Acción del Script | Resultado |
|------------|-------------------|------------|
| **Sin PostgreSQL** | Instala versión compatible según SO | Nueva instalación completa |
| **PostgreSQL 9+ sin datos** | Usa PostgreSQL existente + Bacula | Reutiliza instancia vacía |
| **PostgreSQL con datos producción** | Pide confirmación + Usa existente | Protege bases existentes |
| **PostgreSQL < 9** | Advierte incompatibilidad | Requiere actualización manual |

#### **Mensajes de Protección:**

```
Checking PostgreSQL installation...
   PostgreSQL version detected: 13.7
   ✓ PostgreSQL version compatible: 13.7
   ⚠ PostgreSQL is in use with production databases
   Installing Bacula will use existing PostgreSQL instance
   Existing databases:
     - production_db1
     - erp_system
     - app_database
   Continue using existing PostgreSQL? [S/n]: 
```

#### **Mensajes de Incompatibilidad:**

```
Checking PostgreSQL installation...
   PostgreSQL version detected: 8.4
   ✗ PostgreSQL version incompatible: 8.4
     Minimum required version: 9.x
     Please upgrade PostgreSQL to continue
```

#### **Características de Seguridad:**

- ✅ **Detección automática** de versiones 9+
- ✅ **Protección de datos** existentes
- ✅ **Confirmación explícita** del usuario
- ✅ **Manejo de errores** robusto
- ✅ **Logging detallado** del proceso
- ✅ **Rollback automático** si falla
- ✅ **Selección inteligente** de versión por SO
- ✅ **Validación de compatibilidad** antes de instalar

---

## 🗺️ Mapa de Ruta / Roadmap

### Versión 2.1.1 (Actual) - ✅ Completado
- [x] **Compatibilidad Debian 9+** - Soporte para Stretch a Bookworm
- [x] **Compatibilidad Ubuntu 18.04+** - Soporte para Bionic a Noble
- [x] **PostgreSQL 9+ Support** - Soporte para versiones 9 a 16
- [x] **Selección Automática** - Elige mejor versión por SO
- [x] **Detección Mejorada** - Validación de compatibilidad
- [x] **Mensajes Expandidos** - 25+ mensajes de compatibilidad

### Versión 2.1.0 (Anterior) - ✅ Completado
- [x] **Protección PostgreSQL** - Detección y compatibilidad
- [x] **Instalación Inteligente** - Usa PostgreSQL existente
- [x] **Validación de Datos** - Verificación de bases producción
- [x] **Mensajes Bilingües** - 20 nuevos mensajes PostgreSQL
- [x] **Manejo de Errores** - Recuperación robusta

### Versión 2.2.0 (Próxima) - 🚧 En Desarrollo
- [ ] **Soporte MySQL/MariaDB** - Opción para otros motores
- [ ] **Migración Automática** - Exportar/importar datos
- [ ] **Clúster PostgreSQL** - Soporte para alta disponibilidad
- [ ] **Backup de Configuración** - Exportar/importar settings
- [ ] **Validación Pre-Instalación** - Tests completos del sistema

### Versión 2.3.0 (Futura) - 📋 Planificado
- [ ] **Interfaz Web** - Panel de administración web
- [ ] **API REST** - Integración con sistemas externos
- [ ] **Dashboard de Monitoreo** - Métricas en tiempo real
- [ ] **Notificaciones** - Email/Slack/Telegram
- [ ] **Multi-tenant** - Soporte para múltiples organizaciones

### Versión 3.0.0 (Largo Plazo) - 🎯 Visión
- [ ] **Containerización** - Docker/Kubernetes support
- [ ] **Cloud Integration** - AWS S3, Azure Blob, Google Cloud
- [ ] **Machine Learning** - Optimización automática de respaldos
- [ ] **Blockchain** - Integridad de respaldos con blockchain
- [ ] **Agentes Ligeros** - Soporte para IoT y Edge

---

## 🎯 Casos de Uso / Use Cases

### **Caso 1: Servidor Web en Producción**

**Escenario:** Servidor Apache/Nginx con PostgreSQL existente

**Flujo de Trabajo:**
```bash
# 1. Ejecutar script
sudo ./bacula_backup_manager.sh

# 2. El script detecta PostgreSQL existente
PostgreSQL version detected: 13.4
Existing databases: webapp_db, users_db

# 3. Confirma uso de PostgreSQL existente
Continue using existing PostgreSQL? [S/n]: S

# 4. Configura respaldo web
Backup Path: /var/www/backups
Schedule: Daily at 02:00 AM
Retention: 30 days

# 5. Resultado
✅ Bacula configurado usando PostgreSQL existente
✅ Bases de datos protegidas
✅ Respaldos automáticos activos
```

**Beneficios:**
- 🛡️ **Cero impacto** en bases de datos existentes
- ⚡ **Instalación rápida** sin reinstalar PostgreSQL
- �� **Datos protegidos** con mínima interrupción

### **Caso 2: Servidor de Base de Datos Dedicado**

**Escenario:** Servidor PostgreSQL con múltiples bases críticas

**Flujo de Trabajo:**
```bash
# 1. Detección de múltiples bases
PostgreSQL version detected: 14.2
Existing databases:
  - erp_production
  - crm_system  
  - analytics_db
  - warehouse_db

# 2. Configuración especializada
Director Name: db-backup-server
Backup Path: /backups/postgresql
Compression: GZIP level 9
Type: Incremental

# 3. Respaldos remotos
Remote Host: backup-server.company.com
Connection Type: SSH Tunnel
Remote Path: /backups/db-server
```

**Beneficios:**
- 🔄 **Respaldos incrementales** eficientes
- 🌐 **Replicación remota** segura
- 📊 **Monitoreo centralizado** desde panel web

### **Caso 3: Entorno de Desarrollo/Testing**

**Escenario:** Máquina virtual sin PostgreSQL

**Flujo de Trabajo:**
```bash
# 1. Instalación limpia
PostgreSQL not installed - safe to proceed

# 2. Instalación automática
Installing PostgreSQL 15...
Installing Bacula Director...
Creating database and user...

# 3. Configuración rápida
Quick setup? [Y/n]: Y
Using defaults: /backups, 30 days, daily 02:00
```

**Beneficios:**
- ⚡ **Instalación completa** en 5 minutos
- 🎯 **Configuración por defecto** optimizada
- 🧪 **Entorno aislado** para pruebas

### **Caso 4: Recuperación de Desastres**

**Escenario:** Falla de hardware en servidor principal

**Flujo de Trabajo:**
```bash
# 1. Nuevo servidor con backup remoto configurado
sudo baculamanager --restore

# 2. Selección de respaldo
Available backups:
  [1] 2024-01-15_daily_full
  [2] 2024-01-16_daily_incremental
  [3] 2024-01-17_daily_incremental

# 3. Restauración completa
Restore to: /var/www/html
Database restore: Yes
Verify integrity: Yes

# 4. Validación
✅ Files restored: 15,234 files
✅ Database restored: erp_production
✅ Services started: Apache, PostgreSQL
✅ System online: 192.168.1.50
```

**Beneficios:**
- ⏱️ **RTO mínimo** (Recovery Time Objective)
- 🔍 **Verificación de integridad** automática
- 🚀 **Sistema operativo** en minutos

### **Caso 5: Empresa Multi-sitio**

**Escenario:** Multiple oficinas con centralización

**Arquitectura:**
```
Oficina Principal (Datacenter)
├── PostgreSQL Principal (15.x)
├── Bacula Director
├── Storage Local
└── Túneles SSH a sucursales

Oficina A (Branch)
├── PostgreSQL Existente (13.x)
├── Bacula File Daemon
└── Backup automático a principal

Oficina B (Branch)  
├── Sin PostgreSQL
├── Bacula Full
└── Backup incremental
```

**Configuración:**
```bash
# Servidor Principal
sudo baculamanager --config-director

# Oficina A (con PostgreSQL)
sudo baculamanager --config-client --use-existing-pg

# Oficina B (sin PostgreSQL)
sudo baculamanager --config-client --install-pg
```

**Beneficios:**
- 🏢 **Centralización** de todos los respaldos
- 💰 **Reducción de costos** en infraestructura
- 🔄 **Replicación automática** entre sitios
- 📈 **Escalabilidad** horizontal

---

## 🔧 Troubleshooting

### **Errores de Base de Datos PostgreSQL / PostgreSQL Database Errors**

#### **Error: "Could not open Catalog 'MyCatalog', database 'bacula'"**

**Causa**: PostgreSQL no está configurado correctamente para Bacula.

**Solución paso a paso:**

```bash
# 1. Verificar que PostgreSQL esté instalado y corriendo
sudo systemctl status postgresql

# 2. Si no está instalado, instalarlo:
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib

# 3. Iniciar PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# 4. Verificar que esté corriendo
sudo -u postgres pg_isready

# 5. Crear usuario y base de datos de Bacula manualmente
sudo -u postgres psql -c "CREATE USER bacula WITH PASSWORD 'bacula';"
sudo -u postgres psql -c "CREATE DATABASE bacula OWNER bacula;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE bacula TO bacula;"

# 6. Verificar que se creó correctamente
sudo -u postgres psql -l
sudo -u postgres psql -c "\du"

# 7. Guardar credenciales en archivo de configuración
sudo mkdir -p /etc/bacula-manager
sudo tee /etc/bacula-manager/db_credentials.conf << 'EOF'
DB_NAME=bacula
DB_USER=bacula
DB_PASSWORD=bacula
DB_HOST=localhost
DB_PORT=5432
EOF
sudo chmod 600 /etc/bacula-manager/db_credentials.conf

# 8. Actualizar configuración de Bacula con la contraseña
sudo sed -i 's/dbpassword = .*/dbpassword = "bacula"/g' /etc/bacula/bacula-dir.conf

# 9. Reiniciar servicios
sudo systemctl restart postgresql
sudo systemctl restart bacula-dir
```

---

#### **Error: "Unable to connect to PostgreSQL server. Database=bacula User=bacula"**

**Causas posibles:**
- PostgreSQL no está corriendo
- Contraseña incorrecta
- Permisos de red (pg_hba.conf)
- PostgreSQL escuchando solo en localhost

**Solución:**

```bash
# 1. Verificar estado de PostgreSQL
sudo systemctl status postgresql

# 2. Si está stopped, iniciarlo
sudo systemctl start postgresql

# 3. Verificar configuración de autenticación
sudo cat /etc/postgresql/*/main/pg_hba.conf | grep -v "^#" | grep -v "^$"

# 4. Asegurar que tenga método 'trust' o 'md5' para local
# Debe tener una línea como:
# local   all             all                                     md5
# o
# local   all             all                                     trust

# 5. Reiniciar PostgreSQL después de cambios
sudo systemctl restart postgresql

# 6. Verificar que el puerto está abierto
sudo netstat -tlnp | grep 5432
# o
sudo ss -tlnp | grep 5432

# 7. Probar conexión manual
sudo -u postgres psql -d bacula -c "SELECT 1;"
```

---

#### **Error: "PostgreSQL service is not running"**

**Solución:**

```bash
# Iniciar PostgreSQL
sudo systemctl start postgresql

# Habilitar para inicio automático
sudo systemctl enable postgresql

# Verificar logs si falla
sudo journalctl -u postgresql -n 50

# Verificar espacio en disco (PostgreSQL no inicia sin espacio)
df -h

# Verificar permisos de directorio de datos
sudo ls -la /var/lib/postgresql/
```

---

### **Errores de Configuración Bacula / Bacula Configuration Errors**

#### **Error: "Config error: Could not find config Resource 'ClientName-fd'"**

**Causa**: Falta definición del recurso Client en bacula-dir.conf

**Solución:**

```bash
# 1. Verificar que existe la definición de Client
sudo grep -A 10 "^Client {" /etc/bacula/bacula-dir.conf

# 2. Si no existe, agregarla:
sudo tee -a /etc/bacula/bacula-dir.conf << 'EOF'

Client {
    Name = $(hostname -s)-fd
    Address = 127.0.0.1
    FDPort = 9102
    Catalog = MyCatalog
    Password = "$(openssl rand -base64 16 | tr -d '=+/')"
    File Retention = 30 days
    Job Retention = 6 months
    AutoPrune = yes
}
EOF

# 3. Validar configuración
sudo bacula-dir -t -c /etc/bacula/bacula-dir.conf

# 4. Reiniciar servicio
sudo systemctl restart bacula-dir
```

---

#### **Error: "Config error: Could not find config Resource 'File1'"**

**Causa**: Falta definición del recurso Storage en bacula-dir.conf

**Solución:**

```bash
# 1. Verificar que existe la definición de Storage
sudo grep -A 10 "^Storage {" /etc/bacula/bacula-dir.conf

# 2. Si no existe, agregarla:
sudo tee -a /etc/bacula/bacula-dir.conf << 'EOF'

Storage {
    Name = File1
    Address = 127.0.0.1
    SDPort = 9103
    Password = "$(openssl rand -base64 16 | tr -d '=+/')"
    Device = FileStorage
    Media Type = File
    Maximum Concurrent Jobs = 10
}
EOF

# 3. Validar configuración
sudo bacula-dir -t -c /etc/bacula/bacula-dir.conf

# 4. Reiniciar
sudo systemctl restart bacula-dir
```

---

#### **Error: "Director service restart failed"**

**Pasos de diagnóstico:**

```bash
# 1. Verificar error específico
sudo systemctl status bacula-dir

# 2. Ver logs detallados
sudo journalctl -u bacula-dir -n 100

# 3. Validar sintaxis de configuración
sudo bacula-dir -t -c /etc/bacula/bacula-dir.conf

# 4. Si hay errores de configuración, ver archivo
sudo cat /etc/bacula/bacula-dir.conf | head -50

# 5. Reconfigurar desde cero si es necesario
sudo ./bacula_backup_manager.sh
# Luego seleccionar opción 6 (Reconfigure)

# 6. Solución alternativa: recrear configuración base
sudo cp /etc/bacula/bacula-dir.conf /etc/bacula/bacula-dir.conf.backup.$(date +%Y%m%d)
sudo tee /etc/bacula/bacula-dir.conf << 'EOF'
Director {
    Name = $(hostname -s)-dir
    DIRport = 9101
    QueryFile = "/etc/bacula/scripts/query.sql"
    WorkingDirectory = "/var/lib/bacula"
    PidDirectory = "/run/bacula"
    Maximum Concurrent Jobs = 20
    Password = "$(openssl rand -base64 16 | tr -d '=+/')"
    Messages = Daemon
    DirAddress = 127.0.0.1
}

Catalog {
    Name = MyCatalog
    dbname = "bacula"
    dbuser = "bacula"
    dbpassword = "bacula"
}
EOF
```

---

### **Errores de Instalación / Installation Errors**

#### **Error: "bacula_installed: unbound variable"**

**Causa**: Variable no inicializada en el script

**Solución**: Ya está corregido en versiones recientes. Si persiste:

```bash
# Ejecutar instalación primero
sudo ./bacula_backup_manager.sh
# Seleccionar opción 2 para instalar
```

---

#### **Error: "No internet connectivity detected"**

**Solución:**

```bash
# Verificar conectividad
ping -c 3 google.com

# Si no hay internet, instalar paquetes manualmente
sudo apt-get install -f  # Reintentar con caché local

# O descargar paquetes .deb manualmente en otro equipo
# y transferirlos vía USB/scp

# Instalar desde archivos locales
sudo dpkg -i /path/to/bacula-*.deb
sudo apt-get install -f  # Resolver dependencias
```

---

### **Errores de Respaldo / Backup Errors**

#### **Error: "Backup failed" o "Job terminated with errors"**

**Diagnóstico:**

```bash
# 1. Verificar espacio en disco
df -h

# 2. Verificar estado de servicios
sudo systemctl status bacula-dir bacula-sd bacula-fd

# 3. Ver logs de Bacula
sudo tail -n 100 /var/log/bacula/bacula.log

# 4. Verificar permisos del directorio de respaldo
sudo ls -la /backups/
sudo chown -R bacula:bacula /backups/
sudo chmod 750 /backups/

# 5. Probar backup manualmente
echo "run job=BackupLocalFiles yes" | sudo bconsole

# 6. Verificar conexión entre componentes
echo "status director" | sudo bconsole
echo "status storage" | sudo bconsole
echo "status client" | sudo bconsole
```

---

### **Errores de Permisos / Permission Errors**

#### **Error: "Permission denied accessing /etc/bacula-manager"**

**Solución:**

```bash
# Crear directorios con permisos correctos
sudo mkdir -p /etc/bacula-manager /var/log/bacula-manager
sudo chmod 700 /etc/bacula-manager
sudo chmod 755 /var/log/bacula-manager
sudo chown -R root:root /etc/bacula-manager

# Para directorio de Bacula
sudo mkdir -p /etc/bacula /var/lib/bacula /var/log/bacula
sudo chown -R root:bacula /etc/bacula
sudo chmod 755 /etc/bacula
sudo chmod 640 /etc/bacula/*.conf
sudo chown -R bacula:bacula /var/lib/bacula /var/log/bacula
```

---

### **Errores de SSH / Remote Backup Errors**

#### **Error: "SSH authentication failed"**

**Solución:**

```bash
# 1. Verificar conectividad de red
ping remote_host

# 2. Verificar puerto SSH
nc -zv remote_host 22

# 3. Probar conexión SSH manual
ssh -i /root/.ssh/bacula_backup user@remote_host

# 4. Regenerar claves SSH desde el menú del script
sudo ./bacula_backup_manager.sh
# Opción 10 -> Generar nuevas claves

# 5. Verificar permisos de claves
sudo chmod 600 /root/.ssh/bacula_backup
sudo chmod 644 /root/.ssh/bacula_backup.pub

# 6. Agregar clave al agente SSH
sudo ssh-add /root/.ssh/bacula_backup
```

---

### **Comandos de Diagnóstico Rápido / Quick Diagnostic Commands**

```bash
# Verificar instalación completa
sudo baculamanager --check

# Validar todas las configuraciones
sudo baculamanager --test

# Ver estado detallado
sudo baculamanager --status

# Ver configuración completa
sudo baculamanager --config

# Logs en tiempo real
tail -f /var/log/bacula/bacula.log
tail -f /var/log/bacula-manager/manager.log

# Verificar PostgreSQL
sudo -u postgres psql -c "\l"
sudo -u postgres psql -d bacula -c "\dt"

# Verificar configuración Bacula
sudo bacula-dir -t -c /etc/bacula/bacula-dir.conf
sudo bacula-sd -t -c /etc/bacula/bacula-sd.conf

# Estado de todos los servicios
sudo systemctl status postgresql bacula-dir bacula-sd bacula-fd

# Espacio en disco
df -h /backups /var/lib/bacula
```

---

### **Recuperación Completa / Full Recovery**

Si todo falla, restaurar desde cero:

```bash
# 1. Detener todos los servicios
sudo systemctl stop bacula-dir bacula-sd bacula-fd postgresql

# 2. Backup de configuraciones existentes
sudo tar czf ~/bacula-backup-$(date +%Y%m%d).tar.gz /etc/bacula /etc/bacula-manager 2>/dev/null || true

# 3. Limpiar configuraciones
sudo rm -rf /etc/bacula/*.conf
sudo rm -rf /etc/bacula-manager/*

# 4. Recrear base de datos
sudo -u postgres dropdb bacula 2>/dev/null || true
sudo -u postgres dropuser bacula 2>/dev/null || true

# 5. Volver a ejecutar el script
sudo ./bacula_backup_manager.sh
# Seleccionar opción 2 (Instalar y Configurar)
```

---

### **Contacto y Soporte**

- 📖 **Documentación completa**: Este README.md
- 🐛 **Reporte de bugs**: GitHub Issues
- 💬 **Soporte técnico**: alex.cabello@example.com
- 📹 **Tutoriales video**: Canal de YouTube

---

### Medidas Implementadas

- **Credenciales**: Almacenadas cifradas en base64, permisos 600
- **SSH**: Autenticación solo por clave, `StrictHostKeyChecking=yes`
- **Permisos de Archivos**: Configuración con permisos 600/640
- **Conexiones**: Túneles SSH para conexiones remotas
- **Compresión e Integridad**: GZIP nivel 9 + firmas MD5
- **Variables de Entorno**: Cargadas automáticamente desde archivo seguro

### Credenciales Seguras

Las credenciales se almacenan en:
```
/etc/bacula-manager/environment  # Cifradas en base64, permisos 600
```

Formato:
```
REMOTE_HOST_ENCODED=MTkyLjE2OC4xLjEw
REMOTE_USER_ENCODED=cm9vdA==
```

---

## 👤 Autor / Author

**Alex Cabello Leiva**
- 🎓 Consultor en Innovación y Ciberseguridad

---

<div align="center">

**Desarrollado con ❤️ para proteger tus datos**

</div>
