# Fix bugs — aplicar en orden

## Fix 1 — spacer width en draw_tokyo_frame
**Archivo:** `lib/ui.sh:63`

```bash
# Buscar:
        printf -v sp '%*s' "$((inner - 2))" ''
# Reemplazar:
        printf -v sp '%*s' "$inner" ''
```

## Fix 2 — bar width en custom banners (01-04)
**Archivo:** `lib/banner.sh`

En los 4 banners custom (`banner_custom_01`, `02`, `03`, `04`), la variable `b` se define con `$i` pero debe usar 70.

```bash
# banner_custom_01 — línea 203
# Buscar:
    local i=$((72-6)) b=$(printf '%*s' "$i" '' | tr ' ' '═')
# Reemplazar:
    local i=$((72-6)) b=$(printf '%*s' "$((72-2))" '' | tr ' ' '═')
```

```bash
# banner_custom_02 — línea 219
# Buscar:
    local i=$((72-6)) b=$(printf '%*s' "$i" '' | tr ' ' '─')
# Reemplazar:
    local i=$((72-6)) b=$(printf '%*s' "$((72-2))" '' | tr ' ' '─')
```

```bash
# banner_custom_03 — línea 235
# Buscar:
    local i=$((72-6)) b=$(printf '%*s' "$i" '' | tr ' ' '═')
# Reemplazar:
    local i=$((72-6)) b=$(printf '%*s' "$((72-2))" '' | tr ' ' '═')
```

```bash
# banner_custom_04 — línea 247
# Buscar:
    local i=$((72-6)) b=$(printf '%*s' "$i" '' | tr ' ' '═')
# Reemplazar:
    local i=$((72-6)) b=$(printf '%*s' "$((72-2))" '' | tr ' ' '═')
```

La variable `d` (separador) en banner_04 NO necesita cambio (usa `$i` que es 66, correcto para `__bline`).

## Fix 3 — run_module subshell
**Archivo:** `setup.sh:105`

```bash
# Buscar:
        bash "$file"
# Reemplazar:
        (bash "$file") || true
```

## Fix 4 — guarda TERM_LINES < 15
**Archivo:** `setup.sh`

Agregar después de `TERM_LINES=$(tput lines 2>/dev/null || echo 24)` (línea 56):

```bash
if ((TERM_LINES < 15)); then
    echo -e "${TN_YELLOW}⚠ Terminal demasiado pequeña (${TERM_LINES} líneas) — mínimo 15${RST}"
    exit 1
fi
```

## Verificar
```bash
bash -n lib/ui.sh lib/banner.sh setup.sh
```

## Commit
```bash
git add -A && git commit -m "fix: bugs de ancho en custom banners, spacer, run_module y guarda TERM_LINES"
```
