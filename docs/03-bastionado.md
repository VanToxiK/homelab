# 03. Bastionado

Medidas de seguridad aplicadas tras la instalación. El principio: superficie de ataque mínima, acceso solo con clave, y parches automáticos.

> Los comandos con `sudo` se ejecutan **de uno en uno** (ver [incidencia 4](04-incidencias.md#incidencia-4-comandos-sudo-pegados-de-golpe)).

## 1. Clave SSH ed25519 (en Windows)

Se genera en el equipo cliente, no en el servidor, para que la clave privada nunca salga de él.

```powershell
ssh-keygen -t ed25519 -C "homelab"
```

Crea un par de claves ed25519. Se establece una **passphrase** para que la clave privada esté cifrada en disco. El comentario `homelab` solo identifica la clave.

### Copiar la clave pública al servidor

Windows no incluye `ssh-copy-id`, así que se hace desde PowerShell canalizando la clave pública:

```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh usuario@192.168.X.X "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

Explicación de cada parte del comando remoto:

- `mkdir -p ~/.ssh`: crea la carpeta si no existe.
- `chmod 700 ~/.ssh`: solo el propietario puede acceder.
- `cat >> ~/.ssh/authorized_keys`: añade la clave pública recibida.
- `chmod 600 ~/.ssh/authorized_keys`: solo el propietario puede leer y escribir el archivo (SSH lo exige).

Probar el acceso con clave **antes** de deshabilitar las contraseñas:

```powershell
ssh usuario@192.168.X.X
```

Debe pedir la passphrase de la clave, no la contraseña del usuario.

## 2. Endurecer el servidor SSH

Se crea un archivo propio en `sshd_config.d`, sin tocar el `sshd_config` original:

```bash
sudo nano /etc/ssh/sshd_config.d/10-seguridad.conf
```

Contenido (ver [config/sshd-10-seguridad.conf](../config/sshd-10-seguridad.conf)):

```
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
```

| Directiva | Efecto |
|---|---|
| `PasswordAuthentication no` | Desactiva el login con contraseña |
| `KbdInteractiveAuthentication no` | Cierra la otra vía de contraseña (PAM interactivo) |
| `PermitRootLogin no` | Impide entrar directamente como root |

Validar la sintaxis antes de aplicar:

```bash
sudo sshd -t
```

No muestra nada si la configuración es correcta. Un error aquí evita quedarse sin acceso por un fallo de sintaxis.

Recargar el servicio:

```bash
sudo systemctl reload ssh
```

### Comprobación

Con la sesión actual abierta, abrir una segunda ventana y forzar el uso de contraseña:

```powershell
ssh -o PubkeyAuthentication=no usuario@192.168.X.X
```

Resultado esperado:

```
usuario@192.168.X.X: Permission denied (publickey).
```

Esto confirma que el servidor rechaza cualquier método que no sea la clave. Mantener abierta la primera sesión hasta comprobarlo evita quedarse fuera por error.

## 3. Cortafuegos UFW

Instalar y configurar:

```bash
sudo apt install ufw
```

```bash
sudo ufw default deny incoming
```

```bash
sudo ufw default allow outgoing
```

```bash
sudo ufw limit OpenSSH
```

```bash
sudo ufw enable
```

- `default deny incoming`: bloquea todo el tráfico entrante por defecto.
- `default allow outgoing`: permite las conexiones que inicia el servidor (actualizaciones, DNS...).
- `limit OpenSSH`: permite SSH (22/tcp), pero limita las conexiones repetidas desde una misma IP.
- `enable`: activa UFW y lo deja activo en cada arranque. Se hace **después** de permitir SSH.

Verificar:

```bash
sudo ufw status verbose
```

Muestra la política por defecto y las reglas activas. Ver también [config/ufw-reglas.sh](../config/ufw-reglas.sh).

## 4. Fail2ban

```bash
sudo apt install fail2ban
```

Se crea un jail para SSH que lee del journal de systemd:

```bash
sudo nano /etc/fail2ban/jail.d/sshd.local
```

Contenido (ver [config/fail2ban-jail-sshd.local](../config/fail2ban-jail-sshd.local)):

```ini
[sshd]
enabled  = true
backend  = systemd
port     = ssh
maxretry = 5
findtime = 10m
bantime  = 1h
```

Reiniciar y comprobar:

```bash
sudo systemctl restart fail2ban
```

```bash
sudo fail2ban-client status sshd
```

El segundo comando muestra los intentos fallidos y las IPs bloqueadas.

> Con autenticación solo por clave, Fail2ban es una capa adicional más que la defensa principal: reduce ruido en los logs y frena escaneos. Los valores de `maxretry`, `findtime` y `bantime` son razonables pero no están afinados para este caso.

## 5. Actualizaciones de seguridad automáticas

```bash
sudo apt install unattended-upgrades
```

```bash
sudo dpkg-reconfigure -plow unattended-upgrades
```

Activa el servicio y genera `/etc/apt/apt.conf.d/20auto-upgrades` (ver [config/20auto-upgrades](../config/20auto-upgrades)).

Probar en modo simulación:

```bash
sudo unattended-upgrade --dry-run --debug
```

## 6. Ningún puerto expuesto

El servidor solo es alcanzable desde la red local. No hay redirecciones de puertos en el router. Se puede comprobar qué escucha en el servidor:

```bash
sudo ss -tlnp
```

Lista los puertos TCP en escucha y el proceso asociado. Ahora mismo solo debería aparecer SSH.

Para acceder desde fuera de casa se usará una **VPN mesh (Tailscale) o WireGuard**, en lugar de abrir puertos a Internet. Está en la [hoja de ruta](../README.md#hoja-de-ruta).

## Pendiente / mejoras posibles

- Verificar la firma GPG de `SHA256SUMS` en futuras descargas.
- Revisar periódicamente los logs (`journalctl -u ssh`) y el estado de Fail2ban.
- Definir copias de seguridad.
- Cifrado de disco: no se activó en esta instalación.
