# ====== LexOS Pro ======
# Chargé par ~/.bashrc. Tu peux éditer ce fichier (~/.lexos/lexos.sh).

export PATH="$HOME/bin:$PATH"
alias lex=aide

# ---- Sortie en couleur ----
export CLICOLOR=1
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
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

# ---- Invite orange avec dossier + branche git ----
__lexos_git() {
    local b
    b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
    printf ' \e[38;5;80m(%s)\e[0m' "$b"
}
PS1='\[\e[38;5;208m\]\w\[\e[0m\]$(__lexos_git) \[\e[1;38;5;208m\]❯\[\e[0m\] '

# ---- Bannière d'accueil (une fois par session, en interactif) ----
if [ -z "${LEXOS_MOTD_SHOWN:-}" ] && [ -t 1 ]; then
    export LEXOS_MOTD_SHOWN=1
    printf '\e[1;38;5;208m❯_ LexOS Pro\e[0m  \e[2m· terminal québécois\e[0m\n'
    printf '\e[2mTape\e[0m \e[1;38;5;208maide <ta question>\e[0m \e[2mpour que l'\''IA locale te guide.\e[0m\n'
    printf '\e[2mEx :\e[0m aide comment installer python\n\n'
fi
