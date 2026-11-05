#!/usr/bin/env bash
# =====================================================================
#  install-pc.sh — clone le LOOK du terminal LexOS sur un PC Linux.
#  Mêmes couleurs, même palette, même invite 2 lignes que l'APK.
#
#  En une ligne :
#    curl -fsSL https://raw.githubusercontent.com/alexmarceauprevost812-source/Terminal-LexOS-pro-apk/main/install-pc.sh | bash
#
#  Installe :
#    ~/.lexos/lexos.sh   couleurs + invite (chargé par ~/.bashrc)
#    ~/bin/aide          assistant IA de commandes (optionnel)
#  Sans danger : sauvegarde l'ancien et ne touche pas au reste.
# =====================================================================
set -u
RAW="https://raw.githubusercontent.com/alexmarceauprevost812-source/Terminal-LexOS-pro-apk/main/overlay/app/src/main/assets/lexos"
O=$'\e[1;38;2;248;120;0m'; G=$'\e[1;38;2;118;185;0m'; D=$'\e[2m'; R=$'\e[0m'

echo "${O}❯_ LexOS${R} Installation du look LexOS sur ce PC…"
mkdir -p "$HOME/.lexos" "$HOME/bin"

get() {  # $1 = fichier distant, $2 = destination
    if command -v curl >/dev/null 2>&1; then curl -fsSL "$RAW/$1" -o "$2"
    elif command -v wget >/dev/null 2>&1; then wget -qO "$2" "$RAW/$1"
    else echo "Il faut curl ou wget." >&2; return 1; fi
}

# 1) lexos.sh (couleurs + invite) — sauvegarde l'ancien
[ -f "$HOME/.lexos/lexos.sh" ] && cp "$HOME/.lexos/lexos.sh" "$HOME/.lexos/lexos.sh.bak"
get "lexos.sh" "$HOME/.lexos/lexos.sh" && echo "   ${G}✅ couleurs + invite${R}"

# 2) aide (assistant IA) — optionnel, ne bloque pas si absent
get "aide" "$HOME/bin/aide" 2>/dev/null && chmod +x "$HOME/bin/aide" && echo "   ${G}✅ assistant « aide »${R}"

# 3) ~/bin dans le PATH
case ":$PATH:" in
    *":$HOME/bin:"*) ;;
    *) echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc" ;;
esac

# 4) ~/.bashrc charge lexos.sh (une seule fois)
if ! grep -q '.lexos/lexos.sh' "$HOME/.bashrc" 2>/dev/null; then
    printf '\n# LexOS\n[ -f "$HOME/.lexos/lexos.sh" ] && . "$HOME/.lexos/lexos.sh"\n' >> "$HOME/.bashrc"
fi

echo
echo "${G}Terminé !${R} ${D}Rouvre le terminal, ou tape :${R} ${O}source ~/.lexos/lexos.sh${R}"
echo "${D}Changer le nom de l'invite :${R} ${O}lexos nom ton-nom${R} ${D}(ou édite ~/.lexos/config : LEXOS_NAME=\"...\")${R}"
