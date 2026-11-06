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

# Active blesh à la fin (coloration en direct)
[[ ${BLE_VERSION-} ]] && ble-attach
