#!/usr/bin/env bash
# =====================================================================
#  skin-kali-session.sh — applique le look LexOS DANS la session Kali.
#  Lancé au démarrage de la session XFCE du conteneur kali-lexos
#  (via ~/.local/share/lexos-kali-test/config/autostart/lexos-skin.desktop).
#  Fond d'écran LexOS + thème sombre. N'ÉCRIT rien hors de la session Kali.
# =====================================================================
set -u
WP="$HOME/.lexos/wallpaper.png"

# Attendre que xfconfd (base de config XFCE) réponde, au plus 20 s.
for _ in $(seq 1 20); do
  xfconf-query -c xfce4-desktop -l >/dev/null 2>&1 && break
  sleep 1
done
command -v xfconf-query >/dev/null 2>&1 || exit 0

# --- Fond d'écran LexOS -------------------------------------------------------
if [ -f "$WP" ]; then
  applied=0
  while read -r p; do
    [ -n "$p" ] || continue
    xfconf-query -c xfce4-desktop -p "$p" -s "$WP" 2>/dev/null
    xfconf-query -c xfce4-desktop -p "${p%last-image}image-style" -s 5 2>/dev/null || true
    applied=1
  done < <(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep last-image)
  # Premier démarrage : aucune propriété encore → on crée pour l'écran Xephyr.
  if [ "$applied" = 0 ]; then
    for mon in monitorscreen monitordefault "monitorXephyr Window" monitor0; do
      base="/backdrop/screen0/${mon}/workspace0"
      xfconf-query -c xfce4-desktop -p "$base/last-image"  -n -t string -s "$WP" 2>/dev/null || true
      xfconf-query -c xfce4-desktop -p "$base/image-style" -n -t int    -s 5    2>/dev/null || true
    done
  fi
fi

# --- Thème sombre + icônes (premier disponible dans le conteneur) -------------
pick() { local d="$1"; shift; for t in "$@"; do [ -d "$d/$t" ] && { echo "$t"; return; }; done; }
GTK=$(pick /usr/share/themes Kali-Dark Adwaita-dark Arc-Dark Yaru-dark)
ICON=$(pick /usr/share/icons Flat-Remix-Dark Papirus-Dark kali Adwaita)
[ -n "${GTK:-}" ]  && xfconf-query -c xsettings -p /Net/ThemeName     -s "$GTK"  2>/dev/null
[ -n "${GTK:-}" ]  && xfconf-query -c xfwm4     -p /general/theme     -s "$GTK"  2>/dev/null
[ -n "${ICON:-}" ] && xfconf-query -c xsettings -p /Net/IconThemeName -s "$ICON" 2>/dev/null

# Recharge le bureau pour voir le fond tout de suite.
command -v xfdesktop >/dev/null 2>&1 && xfdesktop --reload >/dev/null 2>&1 &
exit 0
