#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
THEMES_LOG="$BASE_DIR/assets/themeslogs/custom.log"
ICONS_LOG="$BASE_DIR/assets/iconslogs/custom.log"
WALL_LOG="$BASE_DIR/assets/wallpaperlogs/custom.log"

log() {
    local file="$1" status="$2" msg="$3"
    echo "[$status] $(date '+%Y-%m-%d %H:%M:%S') — $msg" >> "$file"
}

install_deps() {
    echo "instalando dependencias..."
    sudo apt install -y git wget unzip gtk2-engines-murrine sassc gnome-themes-extra
    if [ $? -eq 0 ]; then
        log "$THEMES_LOG" "OK" "Dependencias instaladas"
    else
        log "$THEMES_LOG" "FAIL" "Error instalando dependencias"
    fi
}

install_gtk_theme() {
    echo "instalando tema Tokyo Night Storm..."
    git clone --depth 1 https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git /tmp/tokyo-theme
    cd /tmp/tokyo-theme
    ./install.sh --tweaks storm -l
    if [ $? -eq 0 ]; then
        log "$THEMES_LOG" "OK" "Tokyo Night Storm instalado"
    else
        log "$THEMES_LOG" "FAIL" "Error instalando Tokyo Night Storm"
    fi
    cd "$BASE_DIR"
    rm -rf /tmp/tokyo-theme
}

install_papirus() {
    echo "instalando iconos Papirus..."
    sudo add-apt-repository -y ppa:papirus/papirus
    sudo apt update
    sudo apt install -y papirus-icon-theme
    if [ $? -eq 0 ]; then
        log "$ICONS_LOG" "OK" "Papirus instalado"
    else
        log "$ICONS_LOG" "FAIL" "Error instalando Papirus"
    fi
}

install_sea() {
    echo "instalando iconos SEA..."
    git clone --depth 1 https://github.com/linuxdeepin/deepin-icon-theme.git /tmp/deepin-icons
    mkdir -p ~/.icons/Sea/places/scalable
    cp /tmp/deepin-icons/Sea/index.theme ~/.icons/Sea/
    cp /tmp/deepin-icons/Sea/places/scalable/*.svg ~/.icons/Sea/places/scalable/
    if [ $? -eq 0 ]; then
        log "$ICONS_LOG" "OK" "SEA instalado (solo places)"
    else
        log "$ICONS_LOG" "FAIL" "Error instalando SEA"
    fi
    rm -rf /tmp/deepin-icons
}

install_wallpapers() {
    echo "descargando wallpapers Tokyo Night Storm..."
    mkdir -p ~/.local/share/backgrounds/tokyo-night-storm
    git clone --depth 1 https://github.com/tokyo-night/wallpapers.git /tmp/tn-wallpapers
    find /tmp/tn-wallpapers/storm -name "*.png" -exec cp {} ~/.local/share/backgrounds/tokyo-night-storm/ \;
    if [ $? -eq 0 ]; then
        local count
        count=$(ls ~/.local/share/backgrounds/tokyo-night-storm/*.png 2>/dev/null | wc -l)
        log "$WALL_LOG" "OK" "Wallpapers descargados: $count archivos"
    else
        log "$WALL_LOG" "FAIL" "Error descargando wallpapers"
    fi
    rm -rf /tmp/tn-wallpapers
}

install_fonts() {
    echo "instalando JetBrains Mono Nerd Font..."
    wget -q -O /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o -q /tmp/JetBrainsMono.zip -d ~/.fonts/JetBrainsMono
    fc-cache -fv
    rm /tmp/JetBrainsMono.zip
    log "$THEMES_LOG" "OK" "JetBrains Mono Nerd Font instalada"
}

apply_settings() {
    echo "aplicando configuración visual..."

    local gtk_theme
    gtk_theme=$(find ~/.themes -maxdepth 1 -name "*Tokyonight*Storm*" -type d | head -1 | xargs basename 2>/dev/null)

    if [ -n "$gtk_theme" ]; then
        gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
        gsettings set org.gnome.shell.extensions.user-theme name "$gtk_theme"
        log "$THEMES_LOG" "OK" "GTK theme aplicado: $gtk_theme"
    else
        log "$THEMES_LOG" "FAIL" "No se encontró el tema Tokyonight Storm en ~/.themes"
    fi

    gsettings set org.gnome.desktop.interface icon-theme "Sea"
    log "$ICONS_LOG" "OK" "Icon theme: Sea"

    local cursor
    cursor=$(find ~/.icons -maxdepth 1 -name "Bibata*" -type d | head -1 | xargs basename 2>/dev/null)
    if [ -n "$cursor" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "$cursor"
    fi

    local wallpaper
    wallpaper=$(find ~/.local/share/backgrounds/tokyo-night-storm -name "*.png" | shuf -n1)
    if [ -n "$wallpaper" ]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper"
        gsettings set org.gnome.desktop.screensaver picture-uri "file://$wallpaper"
        log "$WALL_LOG" "OK" "Wallpaper aleatorio: $(basename "$wallpaper")"
    else
        log "$WALL_LOG" "FAIL" "No hay wallpapers en ~/.local/share/backgrounds/tokyo-night-storm"
    fi

    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
    log "$THEMES_LOG" "OK" "Botones de ventana: minimize,maximize,close"
}

main() {
    echo "iniciando personalización del sistema..."

    for dir in "$BASE_DIR/assets/themeslogs" "$BASE_DIR/assets/iconslogs" "$BASE_DIR/assets/wallpaperlogs"; do
        mkdir -p "$dir"
    done

    install_deps
    install_gtk_theme
    install_papirus
    install_sea
    install_wallpapers
    install_fonts
    apply_settings

    echo "personalización completada"
    echo "logs en: $BASE_DIR/assets/"
}

main