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
#  IMPORTANT : xfdesktop affiche le fond via last-image MAIS AUSSI
#  last-single-image et image-path. Si on ne change que last-image, l'ancien
#  fond (dragon) revient au rechargement. On règle donc LES TROIS.
if [ -f "$WP" ]; then
  applied=0
  # Toutes les propriétés d'image existantes -> le fond LexOS
  for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E 'last-image|last-single-image|image-path'); do
    xfconf-query -c xfce4-desktop -p "$p" -s "$WP" 2>/dev/null && applied=1
  done
  # Styles : 5 = recadrer pour remplir ; image-show = true
  for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep 'image-style'); do
    xfconf-query -c xfce4-desktop -p "$p" -s 5 2>/dev/null
  done
  for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep 'image-show'); do
    xfconf-query -c xfce4-desktop -p "$p" -s true 2>/dev/null
  done
  # Coupe un éventuel diaporama qui remettrait le dragon
  for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -i 'cycle'); do
    xfconf-query -c xfce4-desktop -p "$p" -s false 2>/dev/null
  done
  # Premier démarrage : aucune propriété encore → on crée pour l'écran courant.
  if [ "$applied" = 0 ]; then
    for mon in monitorscreen monitordefault monitor0 "monitorXephyr Window"; do
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
