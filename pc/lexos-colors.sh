# ====== Couleurs LexOS (comme l'APK) — chargé par ~/.bashrc ======
# N'affecte PAS ton invite (prompt), seulement les couleurs ls/grep/man.
export CLICOLOR=1
export COLORTERM=truecolor
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
command -v bat >/dev/null 2>&1 && alias cat='bat -pp'
command -v eza >/dev/null 2>&1 && alias ls='eza --color=always --icons=auto' && alias ll='eza -lah --color=always --icons=auto'

# Couleurs des fichiers : dossiers/exécutables orange, liens cyan, images rose
# Fichiers téléchargés (archives / paquets) -> BLEU ; dossiers orange, images rose
export LS_COLORS='di=1;38;5;208:ln=38;5;80:ex=38;5;214:so=38;5;208:pi=38;5;214:bd=38;5;214:cd=38;5;214:or=38;5;196:*.tar=1;38;5;39:*.tgz=1;38;5;39:*.zip=1;38;5;39:*.gz=1;38;5;39:*.bz2=1;38;5;39:*.xz=1;38;5;39:*.7z=1;38;5;39:*.rar=1;38;5;39:*.iso=1;38;5;39:*.apk=1;38;5;39:*.aab=1;38;5;39:*.deb=1;38;5;39:*.AppImage=1;38;5;39:*.jpg=38;5;213:*.png=38;5;213:*.jpeg=38;5;213:*.gif=38;5;213:*.mp3=38;5;213:*.mp4=38;5;213:*.pdf=38;5;196:*.md=38;5;80:*.py=38;5;214:*.sh=1;38;5;214:*.json=38;5;80'
# eza utilise sa propre palette : on lui dit aussi de mettre les archives en bleu
export EZA_COLORS='di=1;38;5;208:*.tar=1;38;5;39:*.tgz=1;38;5;39:*.zip=1;38;5;39:*.gz=1;38;5;39:*.bz2=1;38;5;39:*.xz=1;38;5;39:*.7z=1;38;5;39:*.rar=1;38;5;39:*.iso=1;38;5;39:*.apk=1;38;5;39:*.aab=1;38;5;39:*.deb=1;38;5;39:*.AppImage=1;38;5;39'
export GREP_COLORS='ms=1;38;5;208'
# Pages man en couleur (titres orange, mots-clés cyan)
export LESS_TERMCAP_md=$'\e[1;38;5;208m'
export LESS_TERMCAP_us=$'\e[4;38;5;80m'
export LESS_TERMCAP_so=$'\e[1;38;5;214;48;5;236m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
