#!/bin/bash
if ! command -v git &> /dev/null; then
    echo "GIT no esta instalado, procediendo a instalarlo"
    echo "iniciado la instalacion de GIT"
    sudo apt install git -y
    echo "GIT instalado correctamente"
else
    echo "GIT ya esta instalado"
fi
echo "procediendo a configurar GIT" 
echo "ingrese su nombre de Usuario"
read user_name
git config --global user.name "$user_name"
echo "ingrese su correo electronico"
read user_email
git config --global user.email "$user_email"
echo "se configuro GIT con el nombre de usuario: $user_name y el correo electronico: $user_email"
