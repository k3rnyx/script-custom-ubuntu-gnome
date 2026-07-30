#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/lib/ui.sh"

TERM_LOG="$BASE_DIR/assets/terminallogs/custom.log"

log_file() {
    local status="$1" msg="$2"
    echo "[$status] $(date '+%Y-%m-%d %H:%M:%S') — $msg" >> "$TERM_LOG"
}

install_kitty() {
    log_info "Instalando Kitty terminal..."
    sudo apt install -y kitty
    if [ $? -ne 0 ]; then
        log_file "FAIL" "Error instalando Kitty"
        return 1
    fi

    mkdir -p ~/.config/kitty
    wget -q https://raw.githubusercontent.com/aerosol/tokyonight-kitty/master/tokyo-night.conf -O ~/.config/kitty/tokyo-night.conf

    cat > ~/.config/kitty/kitty.conf << 'KITTYCONF'
font_family JetBrainsMono Nerd Font
font_size 12.0
background_opacity 0.9
include tokyo-night.conf
KITTYCONF

    log_file "OK" "Kitty instalado y configurado con Tokyo Night"
}

install_ohmyzsh() {
    log_info "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    git clone --depth 1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k 2>/dev/null
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions 2>/dev/null
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting 2>/dev/null
    git clone --depth 1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions 2>/dev/null

    cat > ~/.zshrc << 'ZSHRC'
export PATH=$HOME/bin:/usr/local/bin:$PATH

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git npm node web-search sudo extract
    copyfile copypath dirhistory
    history-substring-search
    zsh-autosuggestions zsh-syntax-highlighting zsh-completions
)

source $ZSH/oh-my-zsh.sh

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
ZSHRC

    log_file "OK" "Oh My Zsh + p10k + plugins instalados"
}

set_kitty_icon() {
    log_info "Configurando icono de Kitty..."
    local icon_src
    icon_src=$(find ~/.icons -path "*/48x48/apps/kitty.svg" 2>/dev/null | head -1)
    if [ -n "$icon_src" ]; then
        mkdir -p ~/.local/share/icons/hicolor/48x48/apps
        cp "$icon_src" ~/.local/share/icons/hicolor/48x48/apps/kitty.svg
        gtk-update-icon-cache ~/.local/share/icons/ 2>/dev/null || true
        log_file "OK" "Icono de Kitty personalizado (Papirus)"
    else
        log_file "OK" "Icono default de Kitty (Papirus no encontrado)"
    fi
}

set_default_shell() {
    log_info "Cambiando shell default a ZSH..."
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)" && log_file "OK" "Shell default cambiado a ZSH" || log_file "FAIL" "Error cambiando shell (puede requerir contraseña)"
    else
        log_file "OK" "ZSH ya es el shell default"
    fi
}

main() {
    log_info "Configurando terminal..."
    mkdir -p "$(dirname "$TERM_LOG")"
    echo "--- iniciando: $(date '+%Y-%m-%d %H:%M:%S') ---" >> "$TERM_LOG"

    install_kitty
    install_ohmyzsh
    set_kitty_icon
    set_default_shell

    log_ok "Terminal configurada"
    log_detail "Logs: $TERM_LOG"
    echo ""
    echo -e "  ${TN_YELLOW}⚠${RST}  ${TN_FG}Reinicia sesión para usar ZSH como shell default.${RST}"
}

main
