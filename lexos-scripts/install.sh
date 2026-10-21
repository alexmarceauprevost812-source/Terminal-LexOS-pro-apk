#!/data/data/com.termux/files/usr/bin/env bash
# =============================================================================
#  install.sh — installe LexOS Pro dans Termux
# =============================================================================
#  Télécharge/installe les scripts, le thème et l'icône pour arriver
#  sur le terminal LexOS. Couche d'affichage uniquement, ne touche pas
#  au moteur Termux.
#
#  Installation en une ligne (dans Termux) :
#    pkg install -y git && \
#    git clone -b ccr-290bfce8-4waano \
#      https://github.com/alexmarceauprevost812-source/Terminal-LexOS-pro-apk && \
#    bash Terminal-LexOS-pro-apk/lexos-scripts/install.sh
#
#  Ou, depuis un clone déjà présent :
#    bash lexos-scripts/install.sh
# =============================================================================
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"          # .../lexos-scripts
BIN="$HOME/bin"
PFX="${PREFIX:-/data/data/com.termux/files/usr}"

say()  { printf '\033[1;38;2;255;140;0m» %s\033[0m\n' "$1"; }
ok()   { printf '   \033[38;2;57;255;136m✅ %s\033[0m\n' "$1"; }
skip() { printf '   \033[2m— %s\033[0m\n' "$1"; }

say "Installation de LexOS Pro…"

# 1. Dépendances (si on est bien dans Termux)
if command -v pkg >/dev/null 2>&1; then
  say "Paquets requis : dialog chafa git termux-api"
  pkg install -y dialog chafa git termux-api >/dev/null 2>&1 && ok "paquets installés" || skip "paquets : à vérifier"
fi

# 2. Scripts utilisateur -> ~/bin
mkdir -p "$BIN"
if [ -d "$HERE/home-bin" ]; then
  for f in "$HERE"/home-bin/*; do
    [ -e "$f" ] || continue
    b=$(basename "$f")
    cp "$f" "$BIN/$b" && chmod +x "$BIN/$b" && ok "~/bin/$b"
  done
fi

# 3. Scripts système -> $PREFIX/bin
if [ -d "$HERE/prefix-bin" ]; then
  for f in "$HERE"/prefix-bin/*; do
    [ -e "$f" ] || continue
    b=$(basename "$f")
    cp "$f" "$PFX/bin/$b" && chmod +x "$PFX/bin/$b" && ok "\$PREFIX/bin/$b"
  done
fi

# 4. ~/bin dans le PATH (Termux ne l'ajoute pas par défaut)
case ":$PATH:" in
  *":$BIN:"*) skip "~/bin déjà dans le PATH" ;;
  *) echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
     ok "~/bin ajouté au PATH (~/.bashrc)" ;;
esac

# 5. Thème Termux (sauvegarde l'ancien)
if [ -f "$HERE/config/termux.colors.properties" ]; then
  mkdir -p "$HOME/.termux"
  [ -f "$HOME/.termux/colors.properties" ] && cp "$HOME/.termux/colors.properties" "$HOME/.termux/colors.properties.bak"
  cp "$HERE/config/termux.colors.properties" "$HOME/.termux/colors.properties"
  command -v termux-reload-settings >/dev/null 2>&1 && termux-reload-settings
  ok "thème Termux appliqué (ancien → colors.properties.bak)"
fi

# 6. Icône partagée (header / menu)
if [ -f "$HERE/assets/menu-gauche.png" ]; then
  mkdir -p "$HOME/lexos-scripts/assets"
  cp "$HERE/assets/menu-gauche.png" "$HOME/lexos-scripts/assets/menu-gauche.png"
  ok "icône LexOS copiée"
fi

echo
say "Terminé !"
printf '   Tape  \033[1;38;2;255;140;0mlexos\033[0m  pour démarrer, ou relance Termux.\n'

# Aperçu si la lib de couleurs est là
[ -x "$PFX/bin/couleurs.sh" ] && { echo; "$PFX/bin/couleurs.sh" demo 2>/dev/null || true; }
