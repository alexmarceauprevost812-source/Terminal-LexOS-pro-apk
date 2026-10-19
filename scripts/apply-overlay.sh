#!/usr/bin/env bash
# =====================================================================
#  apply-overlay.sh — pose l'interface LexOS Pro par-dessus Termux
#
#  Usage :
#     scripts/apply-overlay.sh <dossier-termux>
#
#  Ne modifie PAS le moteur : copie les fichiers de l'overlay, renomme
#  l'app, et greffe l'appel d'installation LexOS (idempotent).
# =====================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TERMUX_DIR="${1:?Usage: apply-overlay.sh <dossier-termux>}"
APP_NAME="${LEXOS_APP_NAME:-LexOS Pro}"

if [ ! -d "$TERMUX_DIR/app/src/main" ]; then
    echo "Erreur : '$TERMUX_DIR' ne ressemble pas à un dépôt termux-app." >&2
    exit 1
fi

echo "==> Copie de l'overlay dans $TERMUX_DIR"
cp -av "$REPO_DIR/overlay/." "$TERMUX_DIR/" >/dev/null
echo "    overlay copié."

STRINGS="$TERMUX_DIR/app/src/main/res/values/strings.xml"
echo "==> Renommage de l'app en « $APP_NAME »"
# Remplace l'entité du nom (contrôle le libellé du lanceur).
# /e : le remplacement est évalué comme expression → pas de piège d'interpolation.
export LEXOS_APP_NAME="$APP_NAME"
perl -0pi -e 's/<!ENTITY TERMUX_APP_NAME "Termux">/"<!ENTITY TERMUX_APP_NAME \"" . $ENV{LEXOS_APP_NAME} . "\">"/e' "$STRINGS"
grep -q "ENTITY TERMUX_APP_NAME \"$APP_NAME\"" "$STRINGS" \
    && echo "    nom appliqué." \
    || { echo "    AVERTISSEMENT : entité TERMUX_APP_NAME introuvable (déjà renommée ou Termux a changé ?)." >&2; }

INSTALLER="$TERMUX_DIR/app/src/main/java/com/termux/app/TermuxInstaller.java"
echo "==> Greffe de l'installation LexOS dans TermuxInstaller.java"
if grep -q "LexosSetup.run" "$INSTALLER"; then
    echo "    déjà greffé, on saute."
else
    # 1) après une nouvelle installation réussie
    perl -0pi -e 's/(\n(\s*)activity\.runOnUiThread\(whenDone\);)/\n$2LexosSetup.run(activity);$1/' "$INSTALLER"
    # 2) quand le préfixe existe déjà (démarrages suivants / mise à jour)
    perl -0pi -e 's/(\n(\s*)whenDone\.run\(\);\n\s*return;)/\n$2LexosSetup.run(activity);$1/' "$INSTALLER"
    if grep -q "LexosSetup.run" "$INSTALLER"; then
        echo "    greffe appliquée ($(grep -c 'LexosSetup.run' "$INSTALLER") point(s))."
    else
        echo "    ERREUR : impossible de greffer l'appel LexOS (points d'ancrage introuvables)." >&2
        exit 1
    fi
fi

echo "==> Overlay LexOS Pro appliqué avec succès."
