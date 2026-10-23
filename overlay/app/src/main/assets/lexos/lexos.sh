# ====== LexOS Pro ======
# Chargé par ~/.bashrc. Tu peux éditer ce fichier (~/.lexos/lexos.sh).

export PATH="$HOME/bin:$PATH"
alias lex=aide

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
__lexos_ps1() {
    local e=$?
    local o=$'\[\e[38;2;248;120;0m\]' cy=$'\[\e[38;2;54;198;224m\]' z=$'\[\e[0m\]'
    local ok=$'\[\e[1;38;2;248;120;0m\]' ko=$'\[\e[1;31m\]'
    local br="" b
    b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) && br=" ${cy}(${b})${z}"
    local arrow; [ "$e" -eq 0 ] && arrow="${ok}❯${z}" || arrow="${ko}❯${z}"
    PS1="${o}\w${z}${br} ${arrow} "
}
PROMPT_COMMAND=__lexos_ps1

# ---- Accueil (une fois par session, en interactif) — texte propre, sans image ----
if [ -z "${LEXOS_MOTD_SHOWN:-}" ] && [ -t 0 ] && [ -t 1 ]; then
    export LEXOS_MOTD_SHOWN=1
    if command -v lexos-menu >/dev/null 2>&1; then
        lexos-menu
    else
        printf '\e[1;38;2;248;120;0m❯_ LexOS Pro\e[0m  \e[2m· terminal québécois\e[0m\n'
        printf '\e[2mTape\e[0m \e[1;38;2;248;120;0maide <ta question>\e[0m \e[2mpour que l'\''IA locale te guide.\e[0m\n'
    fi
fi

# Active blesh à la fin (coloration en direct)
[[ ${BLE_VERSION-} ]] && ble-attach
