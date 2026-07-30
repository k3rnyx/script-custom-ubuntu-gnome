#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$BASE_DIR" || exit 1

source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/lib/banner.sh"

module_labels=(
    "Instalacion completa"
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

module_desc=(
    "apt update/upgrade + dist-upgrade + snap refresh"
    "nombre, email + claves SSH"
    "temas, iconos, wallpapers + fonts"
    "gestos, dash-to-dock, blur + more"
    "oh-my-zsh, starship, plugins + aliases"
)

selected=(0 0 0 0 0)
current=0
total=${#module_labels[@]}

# zsh 1-indexed array detection
_zoff=0
[[ -z "${module_labels[0]:-}" && -n "${module_labels[1]:-}" ]] && _zoff=1

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
BANNER_ROWS=0

clear_screen() {
    __tc home
    __tc clr
}

_menu_height() {
    local sd=0; ((TERM_LINES >= 25)) && sd=1
    echo $(( total * (sd ? 2 : 1) + 11 ))
}

draw_init() {
    clear_screen
    show_banner | perl -pe 's/\e\[2K\r//g; s/\e\[\?25[lh]//g' > /tmp/tokyo-banner.txt
    BANNER_ROWS=$(wc -l < /tmp/tokyo-banner.txt)

    local mh=$(_menu_height)
    local avail=$((TERM_LINES - mh - 3))
    if ((BANNER_ROWS > avail)); then
        banner_text_only > /tmp/tokyo-banner.txt
        BANNER_ROWS=$(wc -l < /tmp/tokyo-banner.txt)
    fi

    cat /tmp/tokyo-banner.txt
    draw_menu_items
}

draw_menu_items() {
    __tc cup "$BANNER_ROWS"
    __tc clr
    echo

    local mw=$((TERM_W > 80 ? 80 : TERM_W))
    local inner=$((mw - 2))
    local lo=$(((TERM_W - mw) / 2))
    ((lo < 0)) && lo=0
    printf -v lf '%*s' "$lo" ''

    printf -v bar '%*s' "$inner" ''; bar="${bar// /═}"
    local sep_w=$((inner / 2))
    printf -v sep '%*s' "$sep_w" ''; sep="${sep// /─}"
    local sep_l=$(((inner - sep_w) / 2))
    local sep_r=$((inner - sep_l - sep_w))
    printf -v sl '%*s' "$sep_l" ''; printf -v sr '%*s' "$sep_r" ''
    local sd=0; ((TERM_LINES >= 25)) && sd=1

    local pr="${lf}${TN_CYAN}"
    local LM=16
    printf -v LMp '%*s' "$LM" ''

    # ── top border ──
    echo -e "${pr}╔${bar}╗${RST}"

    # ── header ──
    local hdr="${TN_CYAN}◈  CONFIGURATION  ◈${RST}  ${TN_YELLOW}⚡ K3RNYX ⚡${RST}"
    local hv=32 hrp=$(printf '%*s' 27 '')
    echo -e "${pr}║$(printf '%*s' "$((LM + 2))" '')${hdr}${hrp}${TN_CYAN}║${RST}"

    # ── separator ──
    echo -e "${pr}║${sl}${DIM}${sep}${RST}${sr}${TN_CYAN}║${RST}"

    # ── items ──
    for ((idx=0; idx<total; idx++)); do
        local ai=$((idx + _zoff))
        local num=$(printf '%02d' $((idx+1)))
        local lbl="${module_labels[$ai]}"
        local desc="${module_desc[$ai]}"

        local ptr="  " cb="${DIM}○${RST}" nc="${DIM}${TN_PURPLE}" cl="${TN_FG}"
        [[ "$idx" -eq "$current" ]] && ptr="${TN_CYAN}▶${RST} " && cb="${TN_GREEN}${BLD}◉${RST}" && nc="${TN_PURPLE}${BLD}" && cl="${TN_CYAN}${BLD}"
        [[ "${selected[$ai]}" -eq 1 && "$idx" -ne "$current" ]] && cb="${TN_GREEN}◉${RST}" && cl="${TN_GREEN}"

        local line="${ptr}${cb} ${nc}${num}${RST}  ${cl}${lbl}${RST}"
        local plain="  ○ ${num}  ${lbl}"
        local pw=${#plain}
        local li=$((LM + 2))
        local ti=$((inner - li - pw - 2))
        ((ti < 0)) && ti=0
        printf -v tip '%*s' "$ti" ''
        echo -e "${pr}║$(printf '%*s' "$li" '')${line}${tip}  ${TN_CYAN}║${RST}"

        # description line
        if ((sd)); then
            local dplain="         ↳  ${desc}"
            local dw=${#dplain}
            local di=$((inner - li - dw - 2))
            ((di < 0)) && di=0
            printf -v dip '%*s' "$di" ''
            echo -e "${pr}║$(printf '%*s' "$li" '')         ${DIM}${TN_PURPLE}↳  ${desc}${RST}${dip}  ${TN_CYAN}║${RST}"
        fi
    done

    # ── lower separator ──
    echo -e "${pr}║${sl}${DIM}${sep}${RST}${sr}${TN_CYAN}║${RST}"

    # ── footer ──
    local f1="${TN_PURPLE}⚡${RST} ${BLD}${TN_CYAN}[A]${RST} ${TN_FG}Ejecutar todo${RST} ${TN_PURPLE}⚡${RST} ${BLD}${TN_CYAN}[X]${RST} ${TN_FG}Salir${RST}"
    local fv=32 frp=$(printf '%*s' 27 '')
    echo -e "${pr}║$(printf '%*s' "$((LM + 2))" '')${f1}${frp}${TN_CYAN}║${RST}"

    local f2="${DIM}${TN_FG}◈  ↑↓  ·  ◈ Espacio  ·  ◈ Enter${RST}"
    local fv2=31 frp2=$(printf '%*s' 29 '')
    echo -e "${pr}║$(printf '%*s' "$((LM + 2))" '')${f2}${frp2}${TN_CYAN}║${RST}"

    # ── bottom border ──
    echo -e "${pr}╚${bar}╝${RST}"
}

run_module() {
    local idx=$(( $1 + _zoff ))
    local file="${module_files[$idx]}"
    local lbl="${module_labels[$idx]}"
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
    echo -n "  Presiona cualquier tecla para continuar..."; read -rsn1
}

run_selected() {
    local any=0
    for s in "${selected[@]}"; do ((s)) && { any=1; break; } done
    if [ "$any" -eq 0 ]; then
        echo ""
        log_warn "No hay módulos seleccionados"
        echo -n "  Presiona cualquier tecla..."; read -rsn1
        return
    fi

    __tc rmcup
    __tc cnorm
    clear_screen
    draw_tokyo_frame "EJECUTANDO MÓDULOS" "Seleccionados" ""

    for ((i=0; i<total; i++)); do
        ((selected[i + _zoff])) && run_module "$i"
    done

    selected=(0 0 0 0 0)
    echo ""
    log_ok "${BLD}✔ Listo${RST}"
    echo -n "  Presiona cualquier tecla para volver al menú..."; read -rsn1
    __tc smcup
    __tc civis
    draw_init
}

run_all() {
    __tc rmcup
    __tc cnorm
    clear_screen
    draw_tokyo_frame "EJECUTANDO MÓDULOS" "Completos" ""

    for ((i=0; i<total; i++)); do run_module "$i"; done
    echo ""
    log_ok "${BLD}✔ Setup completado${RST}"
    echo -n "  Presiona cualquier tecla para volver al menú..."; read -rsn1
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

_on_resize() {
    TERM_W=$(tput cols 2>/dev/null || echo 72); ((TERM_W < 72)) && TERM_W=72
    TERM_LINES=$(tput lines 2>/dev/null || echo 24)
    draw_init
}
trap _on_resize WINCH

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
            '[H') current=0; draw_menu_items ;;                     # Home
            '[F') current=$((total - 1)); draw_menu_items ;;        # End
        esac
    elif [[ "$key" == ' ' ]]; then
        local ai=$((current + _zoff))
        selected[ai]=$((1 - selected[ai]))
        draw_menu_items
    elif [[ -z "$key" ]]; then
        run_selected
    elif [[ "$key" =~ [aA] ]]; then
        run_all
    elif [[ "$key" == 'g' ]]; then
        current=0; draw_menu_items
    elif [[ "$key" == 'G' ]]; then
        current=$((total - 1)); draw_menu_items
    elif [[ "$key" == 'r' || "$key" == 'R' ]]; then
        selected=(0 0 0 0 0); draw_menu_items
    elif [[ "$key" =~ [1-5] ]]; then
        local n=$((key - 1))
        ((n >= 0 && n < total)) && current=$n && draw_menu_items
    elif [[ "$key" =~ [xXqQ] ]]; then
        cleanup
        echo -e "  ${TN_PURPLE}◈${RST}  ${TN_FG}Hasta luego, ${TN_CYAN}${BLD}K3rNyx${RST}${TN_FG}.${RST}"
        exit 0
    fi
done
