# 02. Instalación

Instalación limpia de Debian 13 "trixie" en el portátil, sin entorno gráfico.

## Punto de partida

El portátil tenía un Ubuntu que fue comprometido. Se considera un equipo **no fiable**, por lo que la instalación borra el disco entero. No se conserva nada del sistema anterior.

## 1. Descargar la imagen y verificar su integridad

Se descargó la imagen **netinst amd64** de Debian 13.7 desde el sitio oficial, junto con el archivo `SHA256SUMS`.

Calcular el hash de la ISO en PowerShell:

```powershell
Get-FileHash .\debian-13.7.0-amd64-netinst.iso -Algorithm SHA256
```

`Get-FileHash` calcula la huella SHA256 del archivo descargado. Debe coincidir exactamente con la línea correspondiente de `SHA256SUMS`. Si no coincide, la descarga está corrupta o manipulada y no debe usarse.

> El nombre exacto del archivo puede variar; usa el que hayas descargado.

Nota: la integridad frente a `SHA256SUMS` protege ante descargas corruptas o alteradas. Para máxima garantía también se debería verificar la firma GPG de `SHA256SUMS`; no se hizo en esta instalación (pendiente como buena práctica).

## 2. Crear el USB de arranque

Con **Rufus 4.15**:

| Opción | Valor |
|---|---|
| Esquema de partición | GPT |
| Sistema de destino | UEFI (no CSM) |
| Sistema de archivos | FAT32 |
| Modo de grabación | **Imagen ISO** |

> El modo de grabación importa: en modo DD la BIOS de este portátil no reconoció el USB. Ver [incidencia 2](04-incidencias.md#incidencia-2-la-bios-no-reconoce-el-usb-grabado-en-modo-dd).

Rufus avisó de un gestor de arranque UEFI revocado. Ver [incidencia 1](04-incidencias.md#incidencia-1-aviso-de-rufus-sobre-gestor-de-arranque-uefi-revocado).

## 3. Arrancar desde el USB

En la BIOS InsydeH2O:

1. Comprobar que **Secure Boot** está desactivado.
2. Poner el USB como primer dispositivo de arranque.
3. Guardar y reiniciar.

## 4. Instalación de Debian

Instalador estándar (modo texto) con estas decisiones:

- **Hostname**: `homelab`.
- **Contraseña de root**: **vacía**. Al dejarla en blanco, el instalador deshabilita la cuenta root y concede `sudo` al usuario normal.
- **Usuario**: cuenta personal con contraseña robusta.
- **Red**: WiFi con IP por DHCP.
- **Particionado**: guiado, usar todo el disco, todo en una única partición. Esto borra el contenido anterior.
- **Selección de programas**: **desmarcar el entorno de escritorio** y marcar solo:
  - Servidor SSH
  - Utilidades estándar del sistema
  - *task laptop* (herramientas de portátil, como gestión de energía y WiFi)

> Cuidado con esta pantalla: se omitió por error en la primera instalación, lo que causó la [incidencia 3](04-incidencias.md#incidencia-3-instalación-accidental-de-gnome-y-eliminación-de-sudo).

## 5. Primer arranque

Iniciar sesión con el usuario creado y comprobar que el sistema está en modo texto:

```bash
systemctl get-default
```

Debe devolver `multi-user.target`. Si devuelve `graphical.target`, ver la incidencia 3.

Comprobar que `sudo` funciona:

```bash
sudo -v
```

`sudo -v` valida las credenciales sin ejecutar nada.

## 6. Ignorar el cierre de la tapa

Al ser un portátil, cerrar la tapa lo suspendería. Se crea un archivo de configuración para evitarlo:

```bash
sudo mkdir -p /etc/systemd/logind.conf.d
sudo nano /etc/systemd/logind.conf.d/tapa.conf
```

Contenido (ver [config/logind-tapa.conf](../config/logind-tapa.conf)):

```ini
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```

Aplicar:

```bash
sudo systemctl restart systemd-logind
```

Reinicia el servicio que gestiona eventos como el cierre de la tapa para que lea la nueva configuración.

## 7. Actualizar el sistema

```bash
sudo apt update
```

```bash
sudo apt full-upgrade
```

`apt update` refresca la lista de paquetes y `apt full-upgrade` instala las actualizaciones pendientes. Se ejecutan por separado y de uno en uno (ver [incidencia 4](04-incidencias.md#incidencia-4-comandos-sudo-pegados-de-golpe)).

## 8. Acceso por SSH

Averiguar la IP actual desde el servidor:

```bash
ip -brief address
```

Desde el equipo Windows:

```powershell
ssh usuario@192.168.X.X
```

La IP la asigna el router por DHCP y puede cambiar. Está previsto fijarla mediante **reserva DHCP en el router**. Como habrá una mudanza, se hará en la nueva red.

Siguiente paso: [03. Bastionado](03-bastionado.md).
