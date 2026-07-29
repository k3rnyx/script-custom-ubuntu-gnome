#!/bin/bash
echo "iniciado el proceso de configuración del Ubuntu"
bash modules/update.sh
echo "actualizando GIT"
bash modules/git.sh
echo "personalizando el sistema"
bash modules/custom.sh