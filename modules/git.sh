#!/bin/bash
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/lib/ui.sh"

if ! command -v git &> /dev/null; then
    log_info "Git no está instalado, instalando..."
    _apt_ensure git
    log_ok "Git instalado correctamente"
else
    log_ok "Git ya está instalado"
fi

log_info "Configurando Git..."
user_name=$(prompt_input "Nombre de usuario para Git" "$(git config --global user.name 2>/dev/null || echo '')")
user_email=$(prompt_input "Correo electrónico para Git" "$(git config --global user.email 2>/dev/null || echo '')")

git config --global user.name "$user_name"
git config --global user.email "$user_email"
log_ok "Git configurado: ${user_name} <${user_email}>"
