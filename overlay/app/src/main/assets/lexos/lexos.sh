# ====== LexOS Pro ======
# Chargé par ~/.bashrc. Tu peux éditer ce fichier (~/.lexos/lexos.sh).

export PATH="$HOME/bin:$PATH"
alias lex=aide

# Nom affiché dans l'invite (modifiable : « lexos nom <ton-nom> »)
[ -f "$HOME/.lexos/config" ] && . "$HOME/.lexos/config"
# Profil (prénom/couleur/niveau), créé par lexos-bienvenue au 1er démarrage
[ -f "$HOME/.lexos/profil" ] && . "$HOME/.lexos/profil"
: "${LEXOS_NAME:=ti-lex}"
: "${LEXOS_COLOR:=248;120;0}"

# Coloration syntaxique de la ligne de commande quand tu tapes (si ble.sh présent)
if [[ $- == *i* ]] && [ -f "$PREFIX/share/blesh/ble.sh" ]; then
    source "$PREFIX/share/blesh/ble.sh" --noattach
fi

# ---- Sortie en couleur ----
export CLICOLOR=1
export COLORTERM=truecolor
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
# Si bat / eza sont installés, on les utilise (encore plus de couleur) :
command -v bat >/dev/null 2>&1 && alias cat='bat -pp'
command -v eza >/dev/null 2>&1 && alias ls='eza --color=always --icons=auto' && alias ll='eza -lah --color=always --icons=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'

# Couleurs de `ls` (dossiers/exécutables en orange, liens en cyan)
export LS_COLORS='di=1;38;5;208:ln=38;5;80:ex=38;5;214:so=38;5;208:pi=38;5;214:bd=38;5;214:cd=38;5;214:or=38;5;196:*.tar=38;5;208:*.zip=38;5;208:*.gz=38;5;208:*.jpg=38;5;213:*.png=38;5;213:*.mp3=38;5;213:*.sh=1;38;5;214'

# Couleur de `grep` (orange)
export GREP_COLORS='ms=1;38;5;208'

# Pages `man` en couleur (titres orange, mots-clés cyan)
export LESS_TERMCAP_md=$'\e[1;38;5;208m'   # gras -> orange
export LESS_TERMCAP_us=$'\e[4;38;5;80m'    # souligné -> cyan
export LESS_TERMCAP_so=$'\e[1;38;5;214;48;5;236m'  # surbrillance
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'

# ---- Invite : dossier orange + branche git cyan + flèche verte/rouge selon le résultat ----
#   ╭──(ti-lex-al)─[~]
#   ╰─(lexos)──➜
# Le nom entre parenthèses vient de LEXOS_NAME (change-le : « lexos nom X »).
__lexos_ps1() {
    local e=$?
    local name="${LEXOS_NAME:-ti-lex}"
    local o=$'\[\e[1;38;2;'"${LEXOS_COLOR:-248;120;0}"$'m\]'   # couleur du profil (ton nom)
    local g=$'\[\e[1;38;2;118;185;0m\]'   # vert lime (lexos)
    local cy=$'\[\e[38;2;54;198;224m\]'   # cyan (dossier)
    local d=$'\[\e[2m\]' z=$'\[\e[0m\]' ko=$'\[\e[1;31m\]'
    local br="" b
    b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) && br=" ${cy}(${b})${z}"
    local arrow; [ "$e" -eq 0 ] && arrow="${g}➜${z}" || arrow="${ko}➜${z}"
    PS1="${d}╭──(${z}${o}${name}${z}${d})─[${z}${cy}\w${z}${d}]${z}${br}\n${d}╰─(${z}${g}lexos${z}${d})──${z}${arrow} "
}
PROMPT_COMMAND=__lexos_ps1

# ---- Mode « explique-moi » (débutant) : avertit avant les commandes risquées ----
if [ "${LEXOS_EXPLIQUE:-off}" = "on" ] && [[ $- == *i* ]] && [ -f "$HOME/.lexos/explique.sh" ]; then
    . "$HOME/.lexos/explique.sh"
fi

# ---- Accueil (une fois par session, en interactif) — texte propre, sans image ----
if [ -z "${LEXOS_MOTD_SHOWN:-}" ] && [ -t 0 ] && [ -t 1 ]; then
    export LEXOS_MOTD_SHOWN=1
    if [ ! -f "$HOME/.lexos/profil" ] && command -v lexos-bienvenue >/dev/null 2>&1; then
        # Tout premier démarrage : configuration (prénom, couleur, niveau)
        lexos-bienvenue
        [ -f "$HOME/.lexos/profil" ] && . "$HOME/.lexos/profil"
    elif command -v lexos-menu >/dev/null 2>&1; then
        lexos-menu
    else
        printf '\e[1;38;2;248;120;0m❯_ LexOS Pro\e[0m  \e[2m· terminal québécois\e[0m\n'
        printf '\e[2mTape\e[0m \e[1;38;2;248;120;0maide <ta question>\e[0m \e[2mpour que l'\''IA locale te guide.\e[0m\n'
    fi
fi

# ---- Autocomplétion en français : commande inconnue -> l'IA propose la vraie ----
# Un seul mot = faute de frappe (comportement normal). Une phrase = demande à l'IA.
command_not_found_handle() {
    local phrase="$*"
    if [ "$#" -lt 2 ]; then
        printf "bash: %s : commande introuvable\n" "$1" >&2
        printf "\e[2m(installer ? pkg install %s   ·   ou demande : aide \"%s\")\e[0m\n" "$1" "$1" >&2
        return 127
    fi
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        printf "bash: %s : commande introuvable\n" "$1" >&2; return 127
    fi
    local url="${LEXAI_LLAMA_URL:-http://127.0.0.1:8080}"
    if ! curl -s --max-time 2 "$url/health" >/dev/null 2>&1 \
       && ! curl -s --max-time 2 "$url/v1/models" >/dev/null 2>&1; then
        printf "\e[2m🤖 L'IA locale n'est pas démarrée.\e[0m Fais : \e[1;38;2;248;120;0mlexos ia\e[0m\n" >&2
        return 127
    fi
    command -v jq >/dev/null 2>&1 || { printf "\e[2m(jq manquant : pkg install jq)\e[0m\n" >&2; return 127; }
    local sys="Tu es l'assistant LexOS Pro (terminal Termux sur Android). On te donne une demande en francais. Reponds par la commande EXACTE a taper, seule sur la premiere ligne (Termux : pkg au lieu de apt, jamais sudo), sans backticks."
    local payload resp cmd
    payload=$(jq -n --arg s "$sys" --arg u "$phrase" '{stream:false,messages:[{role:"system",content:$s},{role:"user",content:$u}]}') || return 127
    printf "\e[2m🤖 LexOS réfléchit…\e[0m\r" >&2
    resp=$(curl -s --max-time 20 "$url/v1/chat/completions" -H 'Content-Type: application/json' -d "$payload" 2>/dev/null)
    printf "\e[K" >&2
    cmd=$(printf '%s' "$resp" | jq -r '.choices[0].message.content // empty' 2>/dev/null \
          | grep -m1 -vE '^[[:space:]]*$' | sed -E 's/^`+//; s/`+$//; s/^[[:space:]]+//; s/[[:space:]]+$//')
    if [ -z "$cmd" ]; then
        printf "\e[2m🤖 Pas de suggestion. Essaie : \e[0maide \"%s\"\n" "$phrase" >&2; return 127
    fi
    if printf '%s' "$cmd" | grep -qiE 'rm +-[rf]|rm +-rf| dd |mkfs|> *\/dev\/|chmod +-R +777|pkg +uninstall'; then
        printf "\e[1;38;2;255;23;68m⚠️  Commande risquée proposée :\e[0m %s\n" "$cmd" >&2
    else
        printf "\e[2m🤖 Tu voulais dire :\e[0m \e[1;38;2;255;215;0m%s\e[0m\n" "$cmd" >&2
    fi
    printf "\e[2m[Entrée = lancer · n = non] ❯ \e[0m"
    local rep=""; read -r rep </dev/tty 2>/dev/null
    case "$rep" in n|N|non|NON|no) return 127 ;; *) eval "$cmd"; return $? ;; esac
}

# Active blesh à la fin (coloration en direct)
[[ ${BLE_VERSION-} ]] && ble-attach
