#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$BASE_DIR" || exit 1

source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/lib/banner.sh"

module_labels=(
    "Actualizar sistema"
    "Configurar GIT"
    "Personalizar sistema"
    "Extensiones GNOME"
    "Configurar terminal"
)

module_files=(
    "modules/update.sh"
    "modules/git.sh"
    "modules/custom.sh"
    "modules/extensions.sh"
    "modules/terminal.sh"
)

selected=(0 0 0 0 0)
current=0
total=${#module_labels[@]}

max_w=0
for lbl in "${module_labels[@]}"; do
    ((${#lbl} > max_w)) && max_w=${#lbl}
done

pad() {
    local s="$1" n="$2"
    local slen=${#s} p=""
    for ((i=slen; i<n; i++)); do p+=" "; done
    echo -n "${s}${p}"
}

# ── terminal control ──────────────────
__tc() {
    local cap="$1"; shift
    case "$cap" in
        home)  tput home  2>/dev/null || echo -ne "\033[H"        ;;
        clr)   tput ed    2>/dev/null || echo -ne "\033[J"        ;;
        el)    tput el    2>/dev/null || echo -ne "\033[K"        ;;
        cup)   tput cup "$1" 0 2>/dev/null || echo -ne "\033[${1}H" ;;
        civis) tput civis 2>/dev/null || echo -ne "\033[?25l"     ;;
        cnorm) tput cnorm 2>/dev/null || echo -ne "\033[?25h"     ;;
        smcup) tput smcup 2>/dev/null || echo -ne "\033[?1049h"   ;;
        rmcup) tput rmcup 2>/dev/null || echo -ne "\033[?1049l"   ;;
    esac
}

TERM_LINES=$(tput lines 2>/dev/null || echo 24)
if ((TERM_LINES < 15)); then
    echo -e "${TN_YELLOW}⚠ Terminal demasiado pequeña (${TERM_LINES} líneas) — mínimo 15${RST}"
    exit 1
fi
MENU_HEIGHT=$((total + 4))
BANNER_ROWS=0

clear_screen() {
    __tc home
    __tc clr
}

draw_init() {
    clear_screen
    show_banner | perl -pe 's/\e\[2K\r//g; s/\e\[\?25[lh]//g' > /tmp/tokyo-banner.txt
    BANNER_ROWS=$(wc -l < /tmp/tokyo-banner.txt)

    local avail=$((TERM_LINES - MENU_HEIGHT - 2))
    if ((BANNER_ROWS > avail)); then
        banner_text_only > /tmp/tokyo-banner.txt
        BANNER_ROWS=$(wc -l < /tmp/tokyo-banner.txt)
    fi

    cat /tmp/tokyo-banner.txt
    draw_menu_items
}

draw_menu_items() {
    __tc cup "$BANNER_ROWS"

    for i in "${!module_labels[@]}"; do
        __tc el
        local lbl=$(pad "${module_labels[i]}" "$max_w")
        local ptr=" " cb="${DIM}·${RST}"
        [[ "$i" -eq "$current" ]] && ptr="${TN_YELLOW}❯${RST}"
        [[ "${selected[i]}" -eq 1 ]] && cb="${TN_GREEN}✓${RST}"
        echo -e "  ${ptr} ${cb}  ${lbl}  ${RST}"
    done

    __tc el; echo ""
    __tc el; echo -e "  ${DIM}[${RST}${BLD}A${RST}${DIM}] Ejecutar todo    ${DIM}[${RST}${BLD}X${RST}${DIM}] Salir${RST}"
    __tc el; echo ""
    __tc el; echo -e "  ${DIM}↑↓ Navegar  ·  Espacio: alternar  ·  Enter: ejecutar${RST}"
}

run_module() {
    local idx=$1
    local file="${module_files[idx]}"
    local lbl="${module_labels[idx]}"
    echo ""
    log_section "$lbl" "▶"
    if [ -f "$file" ]; then
        (bash "$file") || true
    else
        log_error "No se encontró ${file}"
    fi
    echo ""
    log_ok "Completado: ${lbl}"
    echo ""
    read -rsn1 -p "  Presiona cualquier tecla para continuar..."
}

run_selected() {
    local any=0
    for s in "${selected[@]}"; do ((s)) && { any=1; break; } done
    if [ "$any" -eq 0 ]; then
        echo ""
        log_warn "No hay módulos seleccionados"
        read -rsn1 -p "  Presiona cualquier tecla..."
        return
    fi

    __tc rmcup
    __tc cnorm
    clear_screen
    draw_tokyo_frame "EJECUTANDO MÓDULOS" "Seleccionados" ""

    for i in "${!selected[@]}"; do
        ((selected[i])) && run_module "$i"
    done

    selected=(0 0 0 0 0)
    echo ""
    log_ok "${BLD}✔ Listo${RST}"
    read -rsn1 -p "  Presiona cualquier tecla para volver al menú..."
    __tc smcup
    __tc civis
    draw_init
}

run_all() {
    __tc rmcup
    __tc cnorm
    clear_screen
    draw_tokyo_frame "EJECUTANDO MÓDULOS" "Completos" ""

    for i in "${!module_labels[@]}"; do run_module "$i"; done
    echo ""
    log_ok "${BLD}✔ Setup completado${RST}"
    read -rsn1 -p "  Presiona cualquier tecla para volver al menú..."
    __tc smcup
    __tc civis
    draw_init
}

_CLEANED=0
cleanup() {
    ((_CLEANED)) && return
    _CLEANED=1
    rm -f /tmp/tokyo-banner.txt 2>/dev/null
    __tc rmcup 2>/dev/null || true
    __tc cnorm 2>/dev/null || true
}
trap cleanup INT TERM EXIT

__tc smcup
__tc civis
draw_init

while true; do
    read -rsn1 key
    if [[ "$key" == $'\033' ]]; then
        read -rsn2 -t 0.1 key
        case "$key" in
            '[A') ((current = (current - 1 + total) % total)); draw_menu_items ;;
            '[B') ((current = (current + 1) % total)); draw_menu_items ;;
        esac
    elif [[ "$key" == ' ' ]]; then
        selected[current]=$((1 - selected[current]))
        draw_menu_items
    elif [[ -z "$key" ]]; then
        run_selected
    elif [[ "$key" =~ [aA] ]]; then
        run_all
    elif [[ "$key" =~ [xXqQ] ]]; then
        cleanup
        echo ""
        echo -e "${DIM}  ✚ Hasta luego.${RST}"
        echo ""
        exit 0
    fi
done
