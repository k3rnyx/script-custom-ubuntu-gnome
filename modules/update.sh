#!/bin/bash
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/lib/ui.sh"

log_info "Actualizando lista de paquetes..."
if sudo apt update -y && sudo apt upgrade -y; then
    log_ok "Sistema actualizado correctamente"
else
    log_error "Error al actualizar el sistema"
fi
