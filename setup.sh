#!/bin/bash
echo "iniciado el proceso de configuración del Ubuntu"
bash modules/update.sh
echo "actualizando GIT"
bash modules/git.sh
echo "personalizando el sistema"
bash modules/custom.sh
echo "instalando extensiones gnome"
bash modules/extensions.sh
echo "configurando terminal"
bash modules/terminal.sh