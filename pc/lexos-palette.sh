#!/usr/bin/env bash
# ====== Palette LexOS (identique à l'APK) — appliquée au terminal courant ======
# Utilise les séquences OSC (standard) : marche sur la plupart des terminaux.
# À sourcer dans ~/.bashrc pour l'avoir à chaque ouverture.
_c() { printf '\033]4;%d;%s\007' "$1" "$2"; }
_c 0  '#0B1220'; _c 8  '#2A3850'   # noir / gris
_c 1  '#FF1744'; _c 9  '#FF5C77'   # rouge néon
_c 2  '#76B900'; _c 10 '#9BE000'   # vert
_c 3  '#E6C15A'; _c 11 '#FFD67A'   # jaune
_c 4  '#F87800'; _c 12 '#FFA040'   # orange LexOS
_c 5  '#9B7BFF'; _c 13 '#B89BFF'   # magenta
_c 6  '#3BB6D6'; _c 14 '#6FD6EF'   # cyan
_c 7  '#C8D4E6'; _c 15 '#E6EDF7'   # blanc
printf '\033]10;#F3EDE4\007'   # texte (foreground)
printf '\033]11;#000000\007'   # fond (background) noir
printf '\033]12;#F87800\007'   # curseur orange
unset -f _c
