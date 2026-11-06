# ~/.lexos/explique.sh — mode « explique-moi » (débutant).
# Avertit avant une commande risquée et explique les commandes connues.
# Chargé par lexos.sh seulement si LEXOS_EXPLIQUE=on. Couper : lexos explique off.
# Sans danger : ne bloque QUE si tu refuses une commande risquée ; sinon n'empêche rien.

__lexos_exp_dangereux() {
    printf '%s' "$1" | grep -qiE 'rm +-[rf]|rm +-rf| dd |mkfs|> *\/dev\/|chmod +-R +777|:\(\)\{|\bformat\b|wipe|pkg +uninstall|rm +-rf +\/'
}

__lexos_exp_dict() {
    local c=$1 f="$HOME/.lexos/explications.txt" line
    [ -f "$f" ] || return 0
    line=$(grep -m1 "^${c}|" "$f" 2>/dev/null) || return 0
    [ -n "$line" ] && printf '\e[2m  💡 %s\e[0m\n' "${line#*|}" >&2
    return 0
}

# Appelé juste avant la 1re commande tapée à l'invite (motif « preexec »).
__lexos_preexec() {
    [ -n "${__LEXOS_READY:-}" ] || return 0     # seulement la 1re commande après l'invite
    unset __LEXOS_READY
    [ -n "${COMP_LINE:-}" ] && return 0          # pas pendant la complétion
    local cmd="$BASH_COMMAND" first
    first=${cmd%% *}
    if __lexos_exp_dangereux "$cmd"; then
        printf '\e[1;38;2;255;23;68m\n  ⚠️  Commande risquée :\e[0m %s\n' "$cmd" >&2
        __lexos_exp_dict "$first"
        printf '\e[2m  Ça peut effacer/casser des choses. Continuer ? [o/N] \e[0m' >&2
        local rep=""; read -r rep </dev/tty 2>/dev/null
        case "$rep" in o|O|y|Y|oui|OUI) return 0 ;; *) printf '\e[2m  Annulé.\e[0m\n' >&2; return 1 ;; esac
    fi
    __lexos_exp_dict "$first"
    return 0
}

__lexos_exp_mark() { __LEXOS_READY=1; }

# Arme le motif : marque après l'invite, puis trappe DEBUG avant la commande.
case "${PROMPT_COMMAND:-}" in
    *__lexos_exp_mark*) ;;
    *) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__lexos_exp_mark" ;;
esac
shopt -s extdebug 2>/dev/null
trap '__lexos_preexec' DEBUG
