#!/usr/bin/env bash
# =====================================================================
#  skin-kali-session.sh — applique le look LexOS DANS la session Kali.
#  Lancé au démarrage de la session XFCE du conteneur kali-lexos.
#  Un autre processus de Kali remet parfois le fond (dragon) ~1 s après
#  l'ouverture : on ré-applique donc EN BOUCLE pendant ~30 s pour gagner.
# =====================================================================
set -u
WP="$HOME/.lexos/wallpaper.png"

# Attendre que xfconfd réponde (max 25 s).
for _ in $(seq 1 25); do
  xfconf-query -c xfce4-desktop -l >/dev/null 2>&1 && break
  sleep 1
done
command -v xfconf-query >/dev/null 2>&1 || exit 0

appliquer() {
  [ -f "$WP" ] || return 0
  local applied=0 p
  # Toutes les propriétés d'image -> fond LexOS (last-image ET last-single-image ET image-path)
  for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E 'last-image|last-single-image|image-path'); do
    xfconf-query -c xfce4-desktop -p "$p" -s "$WP" 2>/dev/null && applied=1
  done
  for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep 'image-style'); do
    xfconf-query -c xfce4-desktop -p "$p" -s 5 2>/dev/null
  done
  for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep 'image-show'); do
    xfconf-query -c xfce4-desktop -p "$p" -s true 2>/dev/null
  done
  for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -i 'cycle'); do
    xfconf-query -c xfce4-desktop -p "$p" -s false 2>/dev/null
  done
  # Premier démarrage : créer pour l'écran courant si rien n'existe.
  if [ "$applied" = 0 ]; then
    for mon in monitorscreen monitordefault monitor0 "monitorXephyr Window"; do
      base="/backdrop/screen0/${mon}/workspace0"
      xfconf-query -c xfce4-desktop -p "$base/last-image"  -n -t string -s "$WP" 2>/dev/null || true
      xfconf-query -c xfce4-desktop -p "$base/image-style" -n -t int    -s 5    2>/dev/null || true
    done
  fi
  command -v xfdesktop >/dev/null 2>&1 && xfdesktop --reload >/dev/null 2>&1 || true
}

# Thème sombre (une fois)
pick() { local d="$1"; shift; for t in "$@"; do [ -d "$d/$t" ] && { echo "$t"; return; }; done; }
GTK=$(pick /usr/share/themes Kali-Dark Adwaita-dark Arc-Dark Yaru-dark)
ICON=$(pick /usr/share/icons Flat-Remix-Dark Papirus-Dark kali Adwaita)
[ -n "${GTK:-}" ]  && xfconf-query -c xsettings -p /Net/ThemeName     -s "$GTK"  2>/dev/null
[ -n "${GTK:-}" ]  && xfconf-query -c xfwm4     -p /general/theme     -s "$GTK"  2>/dev/null
[ -n "${ICON:-}" ] && xfconf-query -c xsettings -p /Net/IconThemeName -s "$ICON" 2>/dev/null

# Applique tout de suite, puis ré-applique en boucle ~30 s pour battre le
# processus qui remet le dragon ~1 s après l'ouverture.
appliquer
( for _ in $(seq 1 15); do sleep 2; appliquer; done ) >/dev/null 2>&1 &

exit 0
