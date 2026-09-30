# Configuración

Archivos de configuración del servidor `homelab`, comentados. Cada archivo indica la ruta donde se instala en el servidor.

| Archivo | Ruta en el servidor | Función |
|---|---|---|
| [`logind-tapa.conf`](logind-tapa.conf) | `/etc/systemd/logind.conf.d/tapa.conf` | Ignorar el cierre de la tapa del portátil |
| [`sshd-10-seguridad.conf`](sshd-10-seguridad.conf) | `/etc/ssh/sshd_config.d/10-seguridad.conf` | Endurecimiento de SSH |
| [`ufw-reglas.sh`](ufw-reglas.sh) | (se ejecuta una vez) | Reglas del cortafuegos UFW |
| [`fail2ban-jail-sshd.local`](fail2ban-jail-sshd.local) | `/etc/fail2ban/jail.d/sshd.local` | Jail de Fail2ban para SSH |
| [`20auto-upgrades`](20auto-upgrades) | `/etc/apt/apt.conf.d/20auto-upgrades` | Actualizaciones de seguridad automáticas |

> Ningún archivo contiene IPs reales, claves ni contraseñas.
