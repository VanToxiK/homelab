# 01. Hardware

## Equipo

Un portátil HP antiguo que estaba sin uso.

| Componente | Especificación |
|---|---|
| Modelo | HP Pavilion 15-n058ss (código E9M93EA) |
| Procesador | AMD A10-5745M, 4 núcleos, 2,1 GHz |
| Memoria | 8 GB DDR3 |
| Almacenamiento | HDD de 500 GB |
| WiFi | Atheros AR5B125 |
| Firmware | BIOS InsydeH2O con UEFI |

## Por qué un portátil como servidor

- **Coste cero**: el equipo ya existía.
- **Batería integrada**: actúa como un SAI rudimentario ante microcortes.
- **Pantalla y teclado incluidos**: útiles para instalar y para recuperarse de errores de red.
- **Bajo consumo** frente a un PC de sobremesa.

## Limitaciones conocidas

- **HDD mecánico**: es lento y más sensible a golpes. Es el principal cuello de botella.
- **Conexión por WiFi**: menos estable y con más latencia que Ethernet. Es aceptable para empezar.
- **Procesador antiguo**: suficiente para servicios ligeros; habrá que ver cómo responde con varios contenedores.
- **Batería envejecida**: no se debe confiar en ella como protección real.

## Mejoras previstas

- Sustituir el HDD por un **SSD** (mejora notable de rendimiento y fiabilidad).
- Pasar a **Ethernet** si la ubicación definitiva lo permite.

## Ajustes de firmware

- **Secure Boot**: desactivado (ver [incidencia 2](04-incidencias.md#incidencia-2-la-bios-no-reconoce-el-usb-grabado-en-modo-dd)).
- Modo de arranque **UEFI** (sin CSM) y USB como primer dispositivo durante la instalación.
- Tapa: el sistema operativo está configurado para ignorar su cierre (ver [instalación](02-instalacion.md#ignorar-el-cierre-de-la-tapa)).
