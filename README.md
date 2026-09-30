# Homelab: servidor casero con seguridad desde el diseño

Proyecto personal para reconvertir un portátil antiguo en un servidor doméstico, reconstruido desde cero y bastionado desde la primera hora.

## Objetivo

Aprender administración de sistemas Linux y seguridad de forma práctica, dando una segunda vida a un equipo que de otro modo estaría parado, y dejar documentado el proceso, incluidos los errores.

El portátil tuvo Ubuntu instalado y **sufrió un compromiso de seguridad** en el pasado. Por eso se trató como un equipo comprometido: no se intentó "limpiarlo", sino que se **borró el disco completo y se reinstaló desde cero** con una imagen oficial verificada.

## Tecnologías

| Área | Tecnología |
|---|---|
| Sistema operativo | Debian 13.7 "trixie" (amd64), sin entorno gráfico |
| Acceso remoto | OpenSSH, solo autenticación por clave ed25519 |
| Cortafuegos | UFW (deny incoming, límite de conexiones en SSH) |
| Prevención de intrusiones | Fail2ban (jail `sshd` con el journal de systemd) |
| Parches | unattended-upgrades (actualizaciones de seguridad automáticas) |
| Herramientas de creación | Rufus 4.15, PowerShell (`Get-FileHash`, `ssh-keygen`) |

## Hardware

HP Pavilion 15-n058ss (AMD A10-5745M, 8 GB RAM, HDD de 500 GB). Detalles en [docs/01-hardware.md](docs/01-hardware.md).

## Estado actual

- [x] Reinstalación limpia de Debian 13 con imagen verificada por SHA256
- [x] Servidor sin entorno gráfico, administrado por SSH
- [x] Root deshabilitado, administración con `sudo`
- [x] SSH solo con clave, sin contraseñas ni login de root
- [x] Cortafuegos UFW activo
- [x] Fail2ban activo
- [x] Actualizaciones de seguridad automáticas
- [x] Ningún puerto expuesto a Internet
- [ ] Servicios (Docker, monitorización, etc.): pendiente, ver hoja de ruta

El servidor solo es accesible desde la red local. Está conectado por WiFi con IP por DHCP.

## Documentación

| Documento | Contenido |
|---|---|
| [docs/01-hardware.md](docs/01-hardware.md) | Especificaciones del equipo y mejoras previstas |
| [docs/02-instalacion.md](docs/02-instalacion.md) | Preparación del USB e instalación de Debian paso a paso |
| [docs/03-bastionado.md](docs/03-bastionado.md) | SSH, cortafuegos, Fail2ban y actualizaciones |
| [docs/04-incidencias.md](docs/04-incidencias.md) | Problemas encontrados: síntoma, diagnóstico, solución y lección |
| [config/](config/) | Archivos de configuración comentados |

## Hoja de ruta

- [ ] Instalar Docker
- [ ] Uptime Kuma para monitorización
- [ ] Pi-hole (DNS con bloqueo de publicidad)
- [ ] Nextcloud
- [ ] Acceso remoto seguro con Tailscale (o WireGuard), sin abrir puertos
- [ ] Copias de seguridad
- [ ] Cambio del HDD por un SSD
- [ ] Reserva DHCP en el router y migración a la nueva red tras una mudanza

## Convenciones

Los datos sensibles se sustituyen por marcadores (`192.168.X.X`, `usuario`). Este repositorio no contiene IPs reales, claves ni contraseñas.

## Licencia y uso

Documentación de un proyecto de aprendizaje. Cada entorno es distinto: revisa y entiende cualquier comando antes de ejecutarlo en tus propios equipos.
