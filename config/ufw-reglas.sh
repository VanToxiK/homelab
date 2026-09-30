#!/bin/sh
# Reglas del cortafuegos UFW del servidor homelab.
# Se ejecuta UNA vez. Ejecutar los comandos de uno en uno si se copian a mano
# (ver incidencia 4 en docs/04-incidencias.md).
#
# IMPORTANTE: permitir SSH ANTES de activar UFW, o se pierde el acceso remoto.

# Política por defecto: bloquear todo el tráfico entrante...
sudo ufw default deny incoming

# ...y permitir todo el saliente (actualizaciones, DNS, etc.).
sudo ufw default allow outgoing

# Permite SSH (22/tcp) con limitación de frecuencia: UFW bloquea temporalmente
# una IP que abra 6 o más conexiones en 30 segundos (frena fuerza bruta básica).
sudo ufw limit OpenSSH

# Activa el cortafuegos (y lo habilita en el arranque).
sudo ufw enable

# Muestra el estado con las reglas numeradas para verificar.
sudo ufw status verbose
