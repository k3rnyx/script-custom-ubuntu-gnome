#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/lib/ui.sh"

THEMES_LOG="$BASE_DIR/assets/themeslogs/custom.log"
ICONS_LOG="$BASE_DIR/assets/iconslogs/custom.log"
WALL_LOG="$BASE_DIR/assets/wallpaperlogs/custom.log"

log_file() {
    local file="$1" status="$2" msg="$3"
    echo "[$status] $(date '+%Y-%m-%d %H:%M:%S') — $msg" >> "$file"
}

install_deps() {
    log_info "Instalando dependencias..."
    sudo apt install -y git wget unzip gtk2-engines-murrine sassc gnome-themes-extra
    if [ $? -eq 0 ]; then
        log_file "$THEMES_LOG" "OK" "Dependencias instaladas"
    else
        log_file "$THEMES_LOG" "FAIL" "Error instalando dependencias"
    fi
}

install_gtk_theme() {
    log_info "Instalando tema Tokyo Night Storm (macOS + float)..."
    git clone --depth 1 https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git /tmp/tokyo-theme
    cd /tmp/tokyo-theme/themes
    bash install.sh --tweaks storm macos float -c dark -l
    install_result=$?
    sed -i '/#panel {/,/^}/s/border: 2px solid #29a4bd;/border: none;/' ~/.themes/Tokyonight-Dark-Storm/gnome-shell/gnome-shell.css 2>/dev/null || true
    if [ $install_result -eq 0 ]; then
        log_file "$THEMES_LOG" "OK" "Tokyo Night Storm instalado"
    else
        log_file "$THEMES_LOG" "FAIL" "Error instalando Tokyo Night Storm"
    fi
    cd "$BASE_DIR"
    rm -rf /tmp/tokyo-theme
}

install_papirus() {
    log_info "Instalando iconos Papirus (solo base)..."
    git clone --depth 1 https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git /tmp/papirus
    mkdir -p ~/.icons/Papirus
    cp -r /tmp/papirus/Papirus/* ~/.icons/Papirus/
    if [ $? -eq 0 ]; then
        log_file "$ICONS_LOG" "OK" "Papirus base instalado en ~/.icons/"
    else
        log_file "$ICONS_LOG" "FAIL" "Error instalando Papirus"
    fi
    rm -rf /tmp/papirus
}

install_sea() {
    log_info "Instalando iconos SEA (solo folder*)..."
    wget -q https://github.com/linuxdeepin/deepin-icon-theme/archive/master.zip -O /tmp/deepin.zip
    unzip -q /tmp/deepin.zip "deepin-icon-theme-master/Sea/places/scalable/folder*" -d /tmp/deepin
    mkdir -p ~/.icons/Sea/places/scalable
    cp /tmp/deepin/deepin-icon-theme-master/Sea/places/scalable/folder*.svg ~/.icons/Sea/places/scalable/
    cp /tmp/deepin/deepin-icon-theme-master/Sea/index.theme ~/.icons/Sea/
    result=$?
    rm -rf ~/.icons/Sea/apps ~/.icons/Sea/devices ~/.icons/Sea/mimetypes 2>/dev/null
    if [ $result -eq 0 ]; then
        log_file "$ICONS_LOG" "OK" "SEA instalado (solo folder*)"
    else
        log_file "$ICONS_LOG" "FAIL" "Error instalando SEA"
    fi
    rm -rf /tmp/deepin /tmp/deepin.zip
}

install_wallpapers() {
    log_info "Descargando wallpapers Tokyo Night Storm..."
    mkdir -p ~/.local/share/backgrounds/tokyo-night-storm

    wget -q https://raw.githubusercontent.com/tokyo-night/wallpapers/main/storm/minimal/gnome_00_1920x1080.png -P ~/.local/share/backgrounds/tokyo-night-storm/
    wget -q https://raw.githubusercontent.com/tokyo-night/wallpapers/main/storm/minimal/stripes_00_1920x1080.png -P ~/.local/share/backgrounds/tokyo-night-storm/
    wget -q https://raw.githubusercontent.com/tokyo-night/wallpapers/main/storm/abstract/lockscreen_00_1920x1080.png -P ~/.local/share/backgrounds/tokyo-night-storm/
    wget -q https://raw.githubusercontent.com/tokyo-night/wallpapers/main/storm/os/debian_00_1920x1080.png -P ~/.local/share/backgrounds/tokyo-night-storm/

    local count
    count=$(ls ~/.local/share/backgrounds/tokyo-night-storm/*.png 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        log_file "$WALL_LOG" "OK" "Wallpapers descargados: $count archivos"
    else
        log_file "$WALL_LOG" "FAIL" "Error descargando wallpapers"
    fi
}

install_fonts() {
    log_info "Instalando JetBrains Mono Nerd Font..."
    wget -q -O /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o -q /tmp/JetBrainsMono.zip -d ~/.fonts/JetBrainsMono
    fc-cache -fv 2>/dev/null
    rm /tmp/JetBrainsMono.zip
    log_file "$THEMES_LOG" "OK" "JetBrains Mono Nerd Font instalada"
}

install_cursors() {
    log_info "Instalando Material Cursors Light..."
    sudo apt install -y inkscape xcursorgen || {
        log_file "$ICONS_LOG" "FAIL" "Error instalando inkscape/xcursorgen"
        return 1
    }
    git clone --depth 1 https://github.com/varlesh/material-cursors.git /tmp/material-cursors || {
        log_file "$ICONS_LOG" "FAIL" "Error clonando material-cursors"
        return 1
    }
    cd /tmp/material-cursors
    make build || {
        log_file "$ICONS_LOG" "FAIL" "Error compilando cursores"
        cd "$BASE_DIR"
        rm -rf /tmp/material-cursors
        return 1
    }
    mkdir -p ~/.icons
    cp -r dist/material_light_cursors ~/.icons/
    cd "$BASE_DIR"
    rm -rf /tmp/material-cursors
    log_file "$ICONS_LOG" "OK" "Material Cursors Light instalado"
}

apply_settings() {
    log_info "Aplicando configuración visual..."

    local gtk_theme
    gtk_theme=$(find ~/.themes -maxdepth 1 -name "*Tokyonight*Storm*" -type d | head -1 | xargs basename 2>/dev/null)

    if [ -n "$gtk_theme" ]; then
        gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
        gsettings set org.gnome.shell.extensions.user-theme name "$gtk_theme"
        log_file "$THEMES_LOG" "OK" "GTK theme aplicado: $gtk_theme"
    else
        log_file "$THEMES_LOG" "FAIL" "No se encontró el tema Tokyonight Storm en ~/.themes"
    fi

    gsettings set org.gnome.desktop.interface icon-theme "Sea"
    log_file "$ICONS_LOG" "OK" "Icon theme: Sea"

    gsettings set org.gnome.desktop.interface cursor-theme "material_light_cursors"
    log_file "$ICONS_LOG" "OK" "Cursor: material_light_cursors"

    local wallpaper
    wallpaper=$(find ~/.local/share/backgrounds/tokyo-night-storm -name "*.png" | shuf -n1)
    if [ -n "$wallpaper" ]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper"
        gsettings set org.gnome.desktop.screensaver picture-uri "file://$wallpaper"
        log_file "$WALL_LOG" "OK" "Wallpaper aleatorio: $(basename "$wallpaper")"
    else
        log_file "$WALL_LOG" "FAIL" "No hay wallpapers en ~/.local/share/backgrounds/tokyo-night-storm"
    fi

    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
    log_file "$THEMES_LOG" "OK" "Botones de ventana: minimize,maximize,close"
}

main() {
    log_info "Iniciando personalización del sistema..."

    for dir in "$BASE_DIR/assets/themeslogs" "$BASE_DIR/assets/iconslogs" "$BASE_DIR/assets/wallpaperlogs"; do
        mkdir -p "$dir"
    done

    install_deps
    install_gtk_theme
    install_papirus
    install_sea
    install_wallpapers
    install_fonts
    install_cursors
    apply_settings

    log_ok "Personalización completada"
    log_detail "Logs en: $BASE_DIR/assets/"
}

main
