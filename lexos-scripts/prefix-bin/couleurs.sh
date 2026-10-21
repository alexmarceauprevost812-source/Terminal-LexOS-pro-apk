#!/data/data/com.termux/files/usr/bin/bash
# couleurs.sh — thème, couleurs et animations du Terminal LexOS Pro
# ---------------------------------------------------------------------------
# SOURCE UNIQUE de toutes les couleurs (ANSI truecolor 24 bits).
# Reskin d'AFFICHAGE uniquement : ne touche pas au moteur Termux.
#
# À sourcer dans lexos / aide / catalogue :
#     source "$PREFIX/bin/couleurs.sh"
# Puis utiliser les variables $LEXOS_* et les fonctions lexos_*.
#
# Démo (à tester sur le téléphone) :  couleurs.sh demo
# ---------------------------------------------------------------------------

# ─── Thème au repos (rien ne roule) ──────────────────────────────────────
LEXOS_RESET=$'\033[0m'
LEXOS_FG=$'\033[38;2;237;237;237m'    # #EDEDED  texte principal (blanc)
LEXOS_GREY=$'\033[38;2;163;163;163m'  # #A3A3A3  texte secondaire (gris)
LEXOS_DIM=$'\033[38;2;122;122;122m'   # #7A7A7A  indications / aide (gris foncé)

# ─── Couleurs par commande (allumées seulement pendant le travail) ───────
LEXOS_DL=$'\033[38;2;180;107;255m'    # ⬇️  violet  #B46BFF  telecharger/wget/curl/git clone/install
LEXOS_SCAN=$'\033[38;2;34;211;238m'   # 🔍 cyan    #22D3EE  scan/nmap
LEXOS_NET=$'\033[38;2;77;141;255m'    # 📡 bleu    #4D8DFF  ping (et bureau à distance)
LEXOS_OK=$'\033[38;2;57;255;136m'     # 🔄 vert    #39FF88  maj/update/upgrade
LEXOS_DEL=$'\033[38;2;255;159;28m'    # 🔥 orange  #FF9F1C  supprimer/rm/delete
LEXOS_HELP=$'\033[38;2;255;210;63m'   # 📖 jaune   #FFD23F  aide/help
LEXOS_ERR=$'\033[38;2;255;77;109m'    # ❌ rouge   #FF4D6D  commande inconnue / erreur
LEXOS_GAMER=$'\033[38;2;255;43;214m'  # 🌈 rose    #FF2BD6  gamer/rgb (départ de la boucle)

# ─── Couleurs des modes IA ───────────────────────────────────────────────
LEXOS_CHAT=$'\033[38;2;45;212;191m'   # 💬 turquoise #2DD4BF  /chat
LEXOS_CODEX=$'\033[38;2;56;189;248m'  # 🧠 bleu ciel #38BDF8  /codex
LEXOS_AUTO=$'\033[38;2;251;113;133m'  # ⚙️  rose      #FB7185  /auto
LEXOS_AGENT=$'\033[38;2;163;230;53m'  # 🕵️  vert lime #A3E635  /agent
LEXOS_MODEL=$'\033[38;2;232;121;249m' # 🧩 magenta   #E879F9  /model
LEXOS_QUIT=$'\033[38;2;163;163;163m'  # 👋 gris      #A3A3A3  /q

# Palette du mode gamer (boucle, départ rose).
LEXOS_GAMER_PALETTE=(FF2BD6 B46BFF 4D8DFF 22D3EE 39FF88 FFD23F FF9F1C FF4D6D)

# ─── Helpers ─────────────────────────────────────────────────────────────

# lexos_hex RRGGBB  (ou #RRGGBB) -> séquence ANSI avant-plan truecolor
lexos_hex() {
  local h=${1#\#}
  printf '\033[38;2;%d;%d;%dm' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

# lexos_reset -> revient au thème au repos (blanc sur noir)
lexos_reset() { printf '%s%s' "$LEXOS_RESET" "$LEXOS_FG"; }

# lexos_cmd_color <commande> -> la couleur de cette commande
lexos_cmd_color() {
  case "$1" in
    telecharger|télécharger|download|dl|wget|curl|git|pkg|apt|pip|npm) printf '%s' "$LEXOS_DL";;
    scan|nmap)            printf '%s' "$LEXOS_SCAN";;
    ping)                 printf '%s' "$LEXOS_NET";;
    bureau|rdp|vnc)       printf '%s' "$LEXOS_NET";;
    maj|update|upgrade)   printf '%s' "$LEXOS_OK";;
    supprimer|rm|delete)  printf '%s' "$LEXOS_DEL";;
    aide|help)            printf '%s' "$LEXOS_HELP";;
    gamer|rgb)            printf '%s' "$LEXOS_GAMER";;
    *)                    printf '%s' "$LEXOS_ERR";;
  esac
}

# lexos_mode_color </chat|/codex|...> -> la couleur du mode
lexos_mode_color() {
  case "$1" in
    /chat)  printf '%s' "$LEXOS_CHAT";;
    /codex) printf '%s' "$LEXOS_CODEX";;
    /auto)  printf '%s' "$LEXOS_AUTO";;
    /agent) printf '%s' "$LEXOS_AGENT";;
    /model) printf '%s' "$LEXOS_MODEL";;
    /q)     printf '%s' "$LEXOS_QUIT";;
    *)      printf '%s' "$LEXOS_GREY";;
  esac
}

# ─── Animations ──────────────────────────────────────────────────────────

# lexos_spinner <color> <label> <pid>
# Spinner braille dans la couleur donnée, à côté du label, tant que <pid> tourne.
lexos_spinner() {
  local color=$1 label=$2 pid=$3 i=0
  local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
  tput civis 2>/dev/null
  while kill -0 "$pid" 2>/dev/null; do
    printf '\r%s%s %s%s' "$color" "${frames[i]}" "$label" "$LEXOS_RESET"
    i=$(( (i + 1) % ${#frames[@]} ))
    sleep 0.1
  done
  printf '\r\033[K'
  tput cnorm 2>/dev/null
}

# lexos_bar <color> <pct> <label> [extra]
# Dessine UNE ligne de barre de progression, réécrite avec \r (pas de défilement).
lexos_bar() {
  local color=$1 pct=$2 label=$3 extra=${4:-} width=20 i fill bar=''
  fill=$(( pct * width / 100 ))
  for ((i = 0; i < width; i++)); do
    if (( i < fill )); then bar+='█'; else bar+='░'; fi
  done
  if [ -n "$extra" ]; then
    printf '\r%s%s  [%s]  %3d%%  · %s%s' "$color" "$label" "$bar" "$pct" "$extra" "$LEXOS_RESET"
  else
    printf '\r%s%s  [%s]  %3d%%%s' "$color" "$label" "$bar" "$pct" "$LEXOS_RESET"
  fi
}

# lexos_download <fichier> [color]
# Démo de téléchargement : barre violette réécrite sur place, puis coche.
# (Dans le vrai lexos : remplace la sortie brute de curl ; voir curl --progress-bar.)
lexos_download() {
  local file=${1:-modele.gguf} color=${2:-$LEXOS_DL} pct=0
  while (( pct < 100 )); do
    pct=$(( pct + 2 + RANDOM % 7 )); (( pct > 100 )) && pct=100
    lexos_bar "$color" "$pct" "⬇️ $file" "$(( 4 + RANDOM % 4 )).$(( RANDOM % 9 )) Mo/s"
    sleep 0.11
  done
  printf '\n%s💜 %s téléchargé ✅%s\n' "$color" "$file" "$LEXOS_RESET"
}

# lexos_update  -> même barre, en vert
lexos_update() {
  local pct=0
  while (( pct < 100 )); do
    pct=$(( pct + 3 + RANDOM % 8 )); (( pct > 100 )) && pct=100
    lexos_bar "$LEXOS_OK" "$pct" "🔄 Installation"
    sleep 0.09
  done
  printf '\n%s💚 LexOS à jour ✅%s\n' "$LEXOS_OK" "$LEXOS_RESET"
}

# lexos_thinking <color> [cycles]
# « lex réfléchit » : ●○○ → ○●○ → ○○● en boucle.
lexos_thinking() {
  local color=${1:-$LEXOS_CHAT} cycles=${2:-8} c
  local frames=('●○○' '○●○' '○○●' '○●○')
  tput civis 2>/dev/null
  for ((c = 0; c < cycles; c++)); do
    printf '\r%slex %s%s' "$color" "${frames[c % ${#frames[@]}]}" "$LEXOS_RESET"
    sleep 0.25
  done
  printf '\r\033[K'
  tput cnorm 2>/dev/null
}

# lexos_lines <color> <delai> "ligne1" "ligne2" ...
# Affiche les lignes UNE PAR UNE (scan réseau, réponses ping…).
lexos_lines() {
  local color=$1 delay=$2; shift 2
  local l
  for l in "$@"; do
    printf '%s%s%s\n' "$color" "$l" "$LEXOS_RESET"
    sleep "$delay"
  done
}

# lexos_gamer  -> logo/barres qui changent de couleur ~150 ms pendant ~4 s, puis GG.
lexos_gamer() {
  local k c n
  tput civis 2>/dev/null
  for ((k = 0; k < 28; k++)); do
    c=$(lexos_hex "${LEXOS_GAMER_PALETTE[k % ${#LEXOS_GAMER_PALETTE[@]}]}")
    n=$(( 4 + k % 12 ))
    printf '\r%s🌈 %s%s' "$c" "$(printf '█%.0s' $(seq 1 "$n"))" "$LEXOS_RESET"
    sleep 0.15
  done
  printf '\r\033[K%s✨ GG ! 🏆%s\n' "$LEXOS_FG" "$LEXOS_RESET"
  tput cnorm 2>/dev/null
}

# lexos_banner  -> message de démarrage.
lexos_banner() {
  printf '%sDémarrage du moteur en arrière-plan…%s\n' "$LEXOS_DIM" "$LEXOS_RESET"
  printf '%s🧠 IA prête ! Parle-lui directement.%s\n' "$LEXOS_OK" "$LEXOS_RESET"
  printf '%sChoisis un mode, ou tape « aide » 👇%s\n' "$LEXOS_DIM" "$LEXOS_RESET"
}

# ─── Démo (exécuté seulement si on lance le script directement) ──────────
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    demo)
      clear
      lexos_banner
      echo
      lexos_lines "$LEXOS_SCAN" 0.5 \
        '🔍 Scan du réseau local…' \
        '🛰️  192.168.1.1    routeur' \
        '📱  192.168.1.12   téléphone' \
        '💻  192.168.1.20   ordinateur'
      echo
      lexos_download modele.gguf
      echo
      lexos_thinking "$LEXOS_CHAT" 8
      printf '%slex ❯ [réponse de l’IA ici]%s\n\n' "$LEXOS_CHAT" "$LEXOS_RESET"
      lexos_gamer
      lexos_reset; echo
      ;;
    *)
      echo "couleurs.sh — à sourcer : source \"\$PREFIX/bin/couleurs.sh\""
      echo "Démo         : couleurs.sh demo"
      ;;
  esac
fi
