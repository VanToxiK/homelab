# 04. Incidencias

Problemas encontrados durante el proyecto, con el formato **síntoma → diagnóstico → solución → lección aprendida**. Documentar los errores es parte del aprendizaje.

| # | Incidencia | Fase |
|---|---|---|
| 1 | [Aviso de Rufus sobre gestor de arranque UEFI revocado](#incidencia-1-aviso-de-rufus-sobre-gestor-de-arranque-uefi-revocado) | Preparación |
| 2 | [La BIOS no reconoce el USB grabado en modo DD](#incidencia-2-la-bios-no-reconoce-el-usb-grabado-en-modo-dd) | Arranque |
| 3 | [Instalación accidental de GNOME y eliminación de sudo](#incidencia-3-instalación-accidental-de-gnome-y-eliminación-de-sudo) | Instalación |
| 4 | [Comandos sudo pegados de golpe](#incidencia-4-comandos-sudo-pegados-de-golpe) | Administración |

---

## Incidencia 1: aviso de Rufus sobre gestor de arranque UEFI revocado

### Síntoma
Al grabar la imagen, Rufus avisó de que contenía un gestor de arranque UEFI **revocado** (lista DBX de revocación actualizada).

### Diagnóstico
La lista DBX de Secure Boot recoge binarios de arranque que ya no se consideran seguros. Rufus la usa para avisar. El aviso puede significar dos cosas: una ISO manipulada, o una imagen legítima con un componente (como `shim`) antiguo que ha sido revocado posteriormente.

Para distinguir ambos casos se comprobó la integridad de la ISO:

```powershell
Get-FileHash .\debian-13.7.0-amd64-netinst.iso -Algorithm SHA256
```

El hash coincidía con el publicado en el `SHA256SUMS` oficial de Debian, luego la imagen no estaba alterada.

### Solución
Se continuó con la grabación. El equipo tiene Secure Boot desactivado, por lo que la revocación no afecta al arranque.

### Lección aprendida
Un aviso de seguridad no se ignora ni se obedece a ciegas: se investiga. La verificación del hash convirtió una duda en una decisión informada. Además, el aviso se refiere a un gestor de arranque, y su impacto real depende de si Secure Boot está activo.

---

## Incidencia 2: la BIOS no reconoce el USB grabado en modo DD

### Síntoma
Con el USB conectado, el portátil no arrancaba desde él y cargaba en su lugar el GRUB del Ubuntu antiguo instalado en el disco.

### Diagnóstico
Se descartaron las causas habituales:

- **Secure Boot**: ya estaba desactivado.
- **Orden de arranque**: el USB ya estaba en primera posición.

Quedaba la forma de grabar el USB: se había usado el modo **DD**. La BIOS InsydeH2O de este HP no lo detectaba como dispositivo arrancable en UEFI.

### Solución
Regrabar el USB con Rufus en modo **Imagen ISO** (GPT, UEFI sin CSM, FAT32). Con ello la BIOS lo reconoció y arrancó el instalador.

### Lección aprendida
Cuando algo falla, hay que ir cambiando una variable cada vez y empezar por lo que uno controla (el medio de instalación) antes de culpar al hardware. El modo de grabación no es un detalle: algunos firmwares solo aceptan uno de los dos modos.

---

## Incidencia 3: instalación accidental de GNOME y eliminación de sudo

### Síntoma
El sistema arrancó con el escritorio GNOME, que no estaba previsto. Al intentar quitarlo con `tasksel`, se desinstaló también `sudo` y `apt` terminó con un error (código 100).

### Diagnóstico
- **Causa 1**: se omitió por error la pantalla de selección de programas del instalador, y se aplicó la selección por defecto, que incluye el entorno gráfico.
- **Causa 2**: al quitar la tarea del escritorio, el gestor de paquetes propuso eliminar paquetes que dependían de ella, entre ellos `sudo`. Se confirmó sin revisar la lista.
- Sin `sudo`, y con la cuenta root deshabilitada, no había forma directa de administrar el sistema. Se comprobó que las credenciales de `sudo` seguían **en caché** en la sesión, lo que dejaba una ventana para actuar.

### Solución
Aprovechando esa caché, se reinstaló `sudo` de inmediato y se reparó el sistema:

```bash
sudo apt install sudo
```

Reinstala `sudo` mientras las credenciales seguían en caché.

```bash
sudo apt --fix-broken install
```

Repara las dependencias rotas que dejó la operación interrumpida.

```bash
sudo apt install task-ssh-server task-laptop
```

Instala las tareas deseadas: servidor SSH y herramientas de portátil.

```bash
sudo apt autoremove --purge
```

Elimina los paquetes huérfanos del escritorio y sus archivos de configuración.

```bash
sudo systemctl set-default multi-user.target
```

Fija el arranque en modo texto (sin entorno gráfico).

Se comprobó el resultado con `systemctl get-default`.

### Lección aprendida
**Leer siempre lo que va a eliminar el gestor de paquetes antes de confirmar.** Una pregunta de "¿desea continuar?" no es un trámite. Además: la pantalla de selección de programas del instalador es crítica en un servidor. Si la caché de `sudo` hubiera caducado, habría hecho falta un USB de rescate; conviene saber qué margen se tiene antes de actuar.

---

## Incidencia 4: comandos sudo pegados de golpe

### Síntoma
Al pegar en el terminal varios comandos con `sudo` a la vez, solo se ejecutaba el primero de forma correcta. Los siguientes no se ejecutaban o fallaban de forma extraña.

### Diagnóstico
Cuando `sudo` pide la contraseña, lee del teclado. Las líneas pegadas a continuación se **consumieron como respuesta a esa petición** en lugar de ejecutarse como comandos.

### Solución
Ejecutar cada comando `sudo` **por separado**, esperando a que termine y comprobando el resultado antes de lanzar el siguiente. Se repitieron los comandos afectados.

### Lección aprendida
Pegar bloques en un terminal es cómodo pero no da control. En operaciones de administración importa más la trazabilidad que la rapidez. Si se necesita automatizar, se debe usar un script revisado, no pegar líneas. Por eso los comandos de esta documentación aparecen en bloques separados.
