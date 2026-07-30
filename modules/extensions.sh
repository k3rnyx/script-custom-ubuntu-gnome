#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/lib/ui.sh"

EXT_LOG="$BASE_DIR/assets/extensionslogs/custom.log"

log_file() {
    local status="$1" msg="$2"
    echo "[$status] $(date '+%Y-%m-%d %H:%M:%S') — $msg" >> "$EXT_LOG"
}

install_deps() {
    log_info "Instalando dependencias de extensiones..."
    _apt_ensure gir1.2-gtop-2.0 lm-sensors gettext libglib2.0-dev-bin
    if [ $? -eq 0 ]; then
        log_file "OK" "Dependencias de extensiones instaladas"
    else
        log_file "FAIL" "Error instalando dependencias de extensiones"
    fi
}

install_blur_my_shell() {
    log_info "Instalando Blur my Shell..."
    git clone --depth 1 https://github.com/aunetx/blur-my-shell.git /tmp/blur-my-shell 2>/dev/null
    cd /tmp/blur-my-shell
    make install 2>/dev/null
    local result=$?
    cd "$BASE_DIR"
    rm -rf /tmp/blur-my-shell
    if [ $result -eq 0 ]; then
        log_file "OK" "Blur my Shell instalado"
    else
        log_file "FAIL" "Error instalando Blur my Shell"
    fi
}

install_vitals() {
    log_info "Instalando Vitals..."
    mkdir -p ~/.local/share/gnome-shell/extensions
    if [ -d ~/.local/share/gnome-shell/extensions/Vitals@CoreCoding.com ]; then
        rm -rf ~/.local/share/gnome-shell/extensions/Vitals@CoreCoding.com
    fi
    git clone https://github.com/corecoding/Vitals.git ~/.local/share/gnome-shell/extensions/Vitals@CoreCoding.com -b develop 2>/dev/null
    glib-compile-schemas --strict ~/.local/share/gnome-shell/extensions/Vitals@CoreCoding.com/schemas/ 2>/dev/null
    if [ $? -eq 0 ]; then
        log_file "OK" "Vitals instalado"
    else
        log_file "FAIL" "Error instalando Vitals"
    fi
}

install_clipboard_indicator() {
    log_info "Instalando Clipboard Indicator..."
    mkdir -p ~/.local/share/gnome-shell/extensions
    if [ -d ~/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com ]; then
        rm -rf ~/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com
    fi
    git clone https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator.git ~/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com 2>/dev/null
    if [ $? -eq 0 ]; then
        log_file "OK" "Clipboard Indicator instalado"
    else
        log_file "FAIL" "Error instalando Clipboard Indicator"
    fi
}

install_just_perfection() {
    log_info "Instalando Just Perfection..."
    git clone --depth 1 https://gitlab.gnome.org/jrahmatzadeh/just-perfection.git /tmp/just-perfection 2>/dev/null || {
        log_file "FAIL" "Error clonando Just Perfection"
        return 1
    }
    cd /tmp/just-perfection
    if ./scripts/build.sh -i 2>/dev/null; then
        log_file "OK" "Just Perfection instalado"
    else
        log_file "FAIL" "Error instalando Just Perfection (permisos?)"
    fi
    cd "$BASE_DIR"
    rm -rf /tmp/just-perfection
}

install_color_picker() {
    log_info "Instalando gpick..."
    _apt_ensure gpick
    if [ $? -eq 0 ]; then
        log_file "OK" "gpick (color picker) instalado"
    else
        log_file "FAIL" "Error instalando gpick"
    fi
}

configure_dock() {
    log_info "Configurando Dash to Dock..."
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen true
    gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.0
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color false
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 34
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock height-fraction 0.9
    gsettings set org.gnome.shell.extensions.dash-to-dock hide-tooltip false
    gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys true
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'
    gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
    gsettings set org.gnome.shell.extensions.dash-to-dock isolate-monitors true
    gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true
    gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-dominant-color true
    gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'SEGMENTED'
    gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-favorites true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-icons-emblems false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-running false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-or-appspread'
    gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'switch-workspace'
    gsettings set org.gnome.shell.extensions.dash-to-dock shift-click-action 'launch'
    gsettings set org.gnome.shell.extensions.dash-to-dock middle-click-action 'launch'
    gsettings set org.gnome.shell.extensions.dash-to-dock min-alpha 0.2
    gsettings set org.gnome.shell.extensions.dash-to-dock max-alpha 0.8
    gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 0.25
    gsettings set org.gnome.shell.extensions.dash-to-dock hide-delay 0.2
    gsettings set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show true
    gsettings set org.gnome.shell.extensions.dash-to-dock isolate-locations true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-network true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-only-mounted false
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-customize-running-dots false
    gsettings set org.gnome.shell.extensions.dash-to-dock customize-alphas false
    gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items false
    gsettings set org.gnome.shell.extensions.dash-to-dock workspace-agnostic-urgent-windows true
    gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.2
    gsettings set org.gnome.shell.extensions.dash-to-dock force-straight-corner false
    gsettings set org.gnome.shell.extensions.dash-to-dock icon-size-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock pressure-threshold 100.0
    gsettings set org.gnome.shell.extensions.dash-to-dock preview-size-scale 0.0
    gsettings set org.gnome.shell.extensions.dash-to-dock scroll-switch-workspace true
    gsettings set org.gnome.shell.extensions.dash-to-dock scroll-to-focused-application false
    gsettings set org.gnome.shell.extensions.dash-to-dock default-windows-preview-to-open false
    gsettings set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup false
    gsettings set org.gnome.shell.extensions.dash-to-dock dance-urgent-applications true
    gsettings set org.gnome.shell.extensions.dash-to-dock application-counter-overrides-notifications true
    gsettings set org.gnome.shell.extensions.dash-to-dock bolt-support true
    gsettings set org.gnome.shell.extensions.dash-to-dock apply-glossy-effect true
    gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
    log_file "OK" "Dash to Dock configurado"
}

enable_all() {
    log_info "Habilitando extensiones..."
    local uuids=(
        "blur-my-shell@aunetx"
        "Vitals@CoreCoding.com"
        "clipboard-indicator@tudmotu.com"
        "just-perfection-desktop@just-perfection"
        "tiling-assistant@ubuntu.com"
        "ubuntu-dock@ubuntu.com"
    )
    for uuid in "${uuids[@]}"; do
        if gnome-extensions enable "$uuid" 2>/dev/null; then
            log_file "OK" "$uuid habilitada"
        else
            log_file "FAIL" "$uuid no encontrada para habilitar"
        fi
    done
}

main() {
    log_info "Instalando extensiones GNOME..."
    mkdir -p "$(dirname "$EXT_LOG")"
    echo "--- iniciando: $(date '+%Y-%m-%d %H:%M:%S') ---" >> "$EXT_LOG"

    install_deps
    install_blur_my_shell
    install_vitals
    install_clipboard_indicator
    install_just_perfection
    install_color_picker
    configure_dock
    enable_all

    log_ok "Extensiones instaladas y configuradas"
    log_detail "Logs: $EXT_LOG"
    echo ""
    echo -e "  ${TN_YELLOW}⚠${RST}  ${TN_FG}Cierra sesión y vuelve a entrar (o reinicia)${RST}"
    echo -e "  ${TN_FG}para que las extensiones nuevas aparezcan en gnome-extensions.${RST}"
}

main
