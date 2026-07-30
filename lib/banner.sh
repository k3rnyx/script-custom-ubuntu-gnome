#!/bin/bash

run_figlet_banner() {
    local fonts=("slant" "big" "ansi-shadow")
    local idx=$((RANDOM % ${#fonts[@]}))
    local font="${fonts[$idx]}"
    if command -v figlet &>/dev/null; then
        local lines
        mapfile -t lines < <(figlet -f "$font" "UBUNTU SETUP" 2>/dev/null || figlet "UBUNTU SETUP" 2>/dev/null)
        local colors=("$TN_CYAN" "$TN_BLUE" "$TN_PURPLE" "$TN_PINK")
        local inner=70
        printf -v bar '%*s' "$inner" ''; bar=${bar// /═}
        echo
        echo -e "${TN_CYAN}╔${bar}╗${RST}"
        local ci=0
        for line in "${lines[@]}"; do
            local len=${#line} lpad=0 rpad=0
            if ((len < inner)); then
                lpad=$(((inner - len) / 2))
                rpad=$((inner - len - lpad))
            fi
            printf -v lp '%*s' "$lpad" ''
            printf -v rp '%*s' "$rpad" ''
            echo -e "${TN_CYAN}║${RST}${lp}${TN_BG}${colors[$((ci % 4))]}${line}${RST}${rp}${TN_CYAN}║${RST}"
            ci=$((ci + 1))
        done
        printf -v sep '%*s' "$((inner - 8))" ''; sep=${sep// /─}
        echo -e "${TN_CYAN}║${RST}${TN_BG}   ${TN_PURPLE}${sep}${RST}   ${TN_CYAN}║${RST}"
        local sub="Interactive Menu"
        local slen=${#sub}
        local spad=$(((inner - slen) / 2))
        local rpad=$((inner - slen - spad))
        printf -v lp '%*s' "$spad" ''
        printf -v rp '%*s' "$rpad" ''
        echo -e "${TN_CYAN}║${RST}${TN_BG}${lp}${TN_FG}${sub}${rp}${RST}${TN_CYAN}║${RST}"
        echo -e "${TN_CYAN}╚${bar}╝${RST}"
        echo
        return 0
    fi
    return 1
}

run_toilet_banner() {
    local fonts=("future" "metal" "mono9" "smblock")
    local idx=$((RANDOM % ${#fonts[@]}))
    local font="${fonts[$idx]}"
    if command -v toilet &>/dev/null; then
        local lines
        mapfile -t lines < <(toilet -w 70 -f "$font" "UBUNTU SETUP" 2>/dev/null)
        local colors=("$TN_CYAN" "$TN_BLUE" "$TN_PURPLE" "$TN_PINK")
        local inner=70
        printf -v bar '%*s' "$inner" ''; bar=${bar// /═}
        echo
        echo -e "${TN_CYAN}╔${bar}╗${RST}"
        local ci=0
        for line in "${lines[@]}"; do
            local len=${#line} lpad=0 rpad=0
            if ((len < inner)); then
                lpad=$(((inner - len) / 2))
                rpad=$((inner - len - lpad))
            fi
            printf -v lp '%*s' "$lpad" ''
            printf -v rp '%*s' "$rpad" ''
            echo -e "${TN_CYAN}║${RST}${lp}${TN_BG}${colors[$((ci % 4))]}${line}${RST}${rp}${TN_CYAN}║${RST}"
            ci=$((ci + 1))
        done
        printf -v sep '%*s' "$((inner - 8))" ''; sep=${sep// /─}
        echo -e "${TN_CYAN}║${RST}${TN_BG}   ${TN_PURPLE}${sep}${RST}   ${TN_CYAN}║${RST}"
        local sub="Interactive Menu"
        local slen=${#sub}
        local spad=$(((inner - slen) / 2))
        local rpad=$((inner - slen - spad))
        printf -v lp '%*s' "$spad" ''
        printf -v rp '%*s' "$rpad" ''
        echo -e "${TN_CYAN}║${RST}${TN_BG}${lp}${TN_FG}${sub}${rp}${RST}${TN_CYAN}║${RST}"
        echo -e "${TN_CYAN}╚${bar}╝${RST}"
        echo
        return 0
    fi
    return 1
}

generate_ppm_images() {
    if ! command -v python3 &>/dev/null; then
        echo "/tmp/tokyo-banners"
        return
    fi
    local tmp_dir="/tmp/tokyo-banners"
    mkdir -p "$tmp_dir"
    for theme in tower fuji torii lanterns abstract; do
        local file="${tmp_dir}/${theme}.ppm"
        [[ -f "$file" ]] && continue
        python3 -c "
import sys
w, h = 160, 45
pal = {'bg':(26,27,38),'cyan':(125,207,255),'blue':(122,162,247),'purple':(187,154,247),'pink':(247,118,142),'green':(158,206,106),'yellow':(224,175,104),'fg':(192,202,245),'white':(255,255,220)}
t = '$theme'
p = []
for y in range(h):
    for x in range(w):
        r, g, b = pal['bg']
        if t == 'tower':
            r = 26+int(y*10/h); g = 27+int(y*20/h); b = 38+int(y*15/h)
            if (x-130)**2+(y-12)**2<30: r,g,b = 255,255,210
            tx = abs(x-50); ty = y-5
            if ty>0 and tx<6-ty/8 and tx>0: r,g,b = pal['pink']
            if y>38: r,g,b = pal['purple']
        elif t == 'fuji':
            r = 20+int(y*8/h); g = 22+int(y*16/h); b = 30+int(y*12/h)
            dy = y-25; hw = 50-dy*2
            if dy>0 and abs(x-80)<hw:
                f = 1-dy/22; r=int(60+120*f); g=int(50+100*f); b=int(80+140*f)
            if dy>0 and dy<4 and abs(x-80)<hw*0.3: r,g,b = 255,255,250
            if 38<y<42 and int(abs(x/8))%3==0: r,g,b = pal['cyan']
            if (x-40)**2+(y-18)**2<40: r,g,b = pal['pink']
            if y>40: r,g,b = pal['bg']
        elif t == 'torii':
            r = 26+int(y*12/h); g = 27+int(y*20/h); b = 38+int(y*18/h)
            for px in [35,55,105,125]:
                if abs(x-px)<3 and 10<y<40: r,g,b = pal['pink']
            if 7<y<12 and 30<x<130:
                f = 1-abs(x-80)/55; r=int(pal['pink'][0]*f); g=int(pal['pink'][1]*f); b=int(pal['pink'][2]*f)
            if 15<y<18 and 32<x<128: r,g,b = pal['cyan']
            sd = (x-80)**2+(y-30)**2
            if sd<100:
                r2=int(pal['yellow'][0]*(1-sd/200)); g2=int(pal['yellow'][1]*(1-sd/200)); b2=int(pal['yellow'][2]*(1-sd/200))
                r=max(r,r2); g=max(g,g2); b=max(b,b2)
            if y>40: r,g,b = pal['green']; r=int(r*0.4); g=int(g*0.4); b=int(b*0.4)
        elif t == 'lanterns':
            r = 15+int(y*5/h); g = 16+int(y*8/h); b = 22+int(y*6/h)
            for lx,c in [(40,pal['pink']),(80,pal['purple']),(120,pal['cyan'])]:
                if abs(x-lx)<8 and 15<y<35:
                    f = 1-abs(y-25)/12; r=int(c[0]*f); g=int(c[1]*f); b=int(c[2]*f)
                    gd = (x-lx)**2+(y-25)**2
                    if gd<100: gl=1-gd/120; r=min(255,int(r+30*gl)); g=min(255,int(g+20*gl)); b=min(255,int(b+10*gl))
            if (x*7+y*13)%37==0 and y<12: r,g,b = 255,255,240
            if y>38: r=int(r*0.3); g=int(g*0.3); b=int(b*0.3)
        elif t == 'abstract':
            r = 20+int(y*8/h); g = 22+int(y*14/h); b = 30+int(y*10/h)
            for cx,cy,rad,col in [(40,20,18,pal['cyan']),(80,22,15,pal['purple']),(120,18,20,pal['pink'])]:
                d = (x-cx)**2+(y-cy)**2
                if d<rad**2: f=1-d/rad**2; r=int(col[0]*f); g=int(col[1]*f); b=int(col[2]*f)
                if (rad-2)**2<d<(rad-4)**2: r,g,b = 255,255,255
        p.extend([r,g,b])
with open('$file','w') as f:
    f.write('P3\n'+f'{w} {h}\n'+'255\n')
    for i in range(0,len(p),3): f.write(f'{p[i]} {p[i+1]} {p[i+2]}\n')
" 2>/dev/null || true
    done
    echo "$tmp_dir"
}

banner_chafa() {
    local tmp_dir
    tmp_dir=$(generate_ppm_images)
    local themes=("tower" "fuji" "torii" "lanterns" "abstract")
    local idx=$((RANDOM % ${#themes[@]}))
    local img="${tmp_dir}/${themes[$idx]}.ppm"
    if [[ -f "$img" ]] && command -v chafa &>/dev/null; then
        local cols
        cols=$(tput cols 2>/dev/null || echo 80)
        ((cols > 72)) && cols=72
        chafa --color-space=rgb --symbols all --size="${cols}x25" "$img" 2>/dev/null || return 1
        echo
        draw_tokyo_frame "UBUNTU SETUP" "Interactive Menu" ""
        return 0
    fi
    return 1
}

banner_jp2a() {
    if ! command -v jp2a &>/dev/null; then
        return 1
    fi
    local img=""
    [[ -f /usr/share/backgrounds/ubuntu-default-greyscale.png ]] && img="/usr/share/backgrounds/ubuntu-default-greyscale.png"
    [[ -z "$img" && -f /usr/share/backgrounds/warty-final-ubuntu.png ]] && img="/usr/share/backgrounds/warty-final-ubuntu.png"
    [[ -z "$img" && -f /usr/share/backgrounds/ubuntu-groovy-wallpaper.png ]] && img="/usr/share/backgrounds/ubuntu-groovy-wallpaper.png"
    [[ -z "$img" ]] && return 1
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    ((cols > 72)) && cols=72
    jp2a --colors --width="$cols" "$img" 2>/dev/null || return 1
    echo
    draw_tokyo_frame "UBUNTU SETUP" "Interactive Menu" ""
    return 0
}

banner_text_only() {
    draw_tokyo_frame "UBUNTU SETUP" "Interactive Menu" ""
}

show_banner() {
    local renderers=()
    command -v chafa &>/dev/null && renderers+=(banner_chafa)
    command -v jp2a &>/dev/null && renderers+=(banner_jp2a)
    command -v toilet &>/dev/null && renderers+=(run_toilet_banner)
    command -v figlet &>/dev/null && renderers+=(run_figlet_banner)

    if [[ ${#renderers[@]} -gt 0 ]]; then
        local idx=$((RANDOM % ${#renderers[@]}))
        "${renderers[$idx]}" && return
    fi

    banner_text_only
}
