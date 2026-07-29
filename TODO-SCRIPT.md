# TODO-SCRIPT.md — Ubuntu Setup Personalization

## Progreso

- [x] `modules/update.sh` — Actualizar sistema (`apt update && apt upgrade`)
- [x] `modules/git.sh` — Instalar y configurar Git
- [x] `modules/custom.sh` — Personalización del sistema

---

## 1. Apariencia Visual (custom.sh)

- [ ] **Tema GTK Tokyo Night** — Descargar e instalar en `~/.themes/`
- [ ] **Tema GNOME Shell Tokyo Night** — Aplicar tema del shell
- [ ] **Iconos** — Descargar e instalar set compatible (Tela-circle / Tokyo Night icons) en `~/.icons/`
- [ ] **Cursores** — Tema de cursores (ej. Bibata, capitaine-cursors)
- [ ] **Wallpaper Tokyo Night** — Descargar y aplicar con `gsettings set org.gnome.desktop.background picture-uri`
- [ ] **Lock Screen** — Aplicar wallpaper de bloqueo con `gsettings set org.gnome.desktop.screensaver picture-uri`
- [ ] **Fuentes** — Configurar fuente del sistema, monoespaciada y documentos

### Logging
- [ ] Registrar instalación de temas en `assets/themeslogs/`
- [ ] Registrar instalación de iconos en `assets/iconslogs/`
- [ ] Registrar instalación de wallpaper en `assets/wallpaperlogs/`

---

## 2. GNOME Shell Extensions

- [ ] Instalar `chrome-gnome-shell` y `gnome-shell-extension-manager`
- [ ] **Dash to Dock** — Personalizar dock (posición, tamaño, auto-ocultar)
- [ ] **Blur my Shell** — Efecto de desenfoque en panel y overview
- [ ] **Vitals** — Monitor de recursos en panel superior
- [ ] **Clipboard Indicator** — Historial del portapapeles
- [ ] **User Themes** — Permitir temas de shell personalizados
- [ ] **AppIndicator and KStatusNotifierItem Support** — Iconos de bandeja

---

## 3. Comportamiento del Escritorio

- [ ] Desactivar animaciones (`gsettings set org.gnome.desktop.interface enable-animations false`)
- [ ] Hot Corner — Activar/desactivar (`gsettings set org.gnome.shell enable-hot-corners`)
- [ ] Workspaces — Configurar dinámicos/fijos, número de workspaces
- [ ] Super key behaviour — Abrir overview o aplicaciones

---

## 4. Terminal

- [ ] Instalar y configurar **ZSH** como shell por defecto
- [ ] Instalar **Oh My Zsh** o **starship** para prompt personalizado
- [ ] Aplicar tema Tokyo Night a la terminal (GNOME Terminal o kitty/alacritty)
- [ ] Configurar fuente monoespaciada (JetBrains Mono, Nerd Fonts, Fira Code)
- [ ] Transparencia y opacidad de la terminal

---

## 5. Panel y Barra Superior

- [ ] Configurar formato del reloj (24h, segundos, fecha)
- [ ] Mostrar porcentaje de batería (`gsettings set org.gnome.desktop.interface show-battery-percentage true`)
- [ ] Mostrar siempre el menú de sonido
- [ ] Personalizar menú de red

---

## 6. Gestión de Ventanas

- [ ] Mostrar botones de minimizar/maximizar (`gsettings set org.gnome.desktop.wm.preferences button-layout`)
- [ ] Focus follows mouse / raise on click
- [ ] Atajos de teclado personalizados (`gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings`)
- [ ] Tiling automático (con extensiones como gTile o Forge)

---

## 7. Firmware / Boot

- [ ] Tema de **GRUB** (fondo, colores, resolución, timeout)
- [ ] Tema de **GDM** (pantalla de inicio de sesión)
- [ ] Tema de **Plymouth** (splash de arranque)

---

## 8. Sonidos

- [ ] Tema de sonido personalizado
- [ ] Alertas y sonidos del sistema (inicio, cierre, notificaciones)

---

## 9. Aplicaciones Esenciales (nuevo módulo)

- [ ] `modules/apps.sh` — Instalación de aplicaciones:
  - Navegador (Firefox, Brave, Chrome)
  - Visual Studio Code
  - Docker y Docker Compose
  - Node.js / npm / nvm
  - Python / pip / pyenv
  - VLC / MPV
  - Flatpak / Flathub
  - Timeshift (backups)
  - Synaptic (gestor de paquetes gráfico)

---

## 10. Red y Privacidad

- [ ] Configurar **UFW** (firewall)
- [ ] Cambiar **hostname**
- [ ] Configurar **DNS** personalizado (Cloudflare 1.1.1.1, Google 8.8.8.8)
- [ ] Configurar **VPN** (WireGuard / OpenVPN)

---

## 11. Refactorización General

- [ ] Mover funciones comunes a `lib/common.sh` (logging, detección de SO, colores)
- [ ] Mover variables y rutas a `config/settings.conf`
- [ ] Añadir menú interactivo para elegir qué módulos ejecutar
- [ ] Añadir logging general con timestamps
- [ ] Añadir flags para modo silencioso/no-interactivo
- [ ] Verificar conectividad a Internet antes de ejecutar
- [ ] Verificar permisos `sudo` antes de ejecutar

---

## Leyenda

- `[ ]` Pendiente
- `[x]` Completado
