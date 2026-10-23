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

# Patche app/build.gradle de Termux : ajoute une signature "release" lisant les
# variables d'env (secrets GitHub), rend le versionCode pilotable par env (pour
# qu'il monte à chaque build), et désactive minify sur release (proguard pourrait
# casser l'overlay LexOS). Aucun mot de passe en dur. Idempotent.
patch_build_gradle() {
    local BG="$TERMUX_DIR/app/build.gradle"
    [ -f "$BG" ] || { echo "    AVERTISSEMENT : app/build.gradle introuvable." >&2; return 0; }
    echo "==> Patch signature & versionCode dans app/build.gradle"

    if grep -qE 'versionCode[[:space:]]+[0-9]+' "$BG"; then
        perl -0pi -e 's/versionCode\s+\d+/versionCode (System.getenv("LEXOS_VERSION_CODE") ?: "118").toInteger()/' "$BG"
        echo "    versionCode -> LEXOS_VERSION_CODE"
    fi

    if ! grep -q 'LEXOS_STORE_FILE' "$BG"; then
        perl -0pi -e 's/(signingConfigs\s*\{\n)(\s*)(debug\s*\{)/${1}${2}release {\n${2}    storeFile file(System.getenv("LEXOS_STORE_FILE") ?: "lexos-release.keystore")\n${2}    keyAlias System.getenv("LEXOS_KEY_ALIAS") ?: "lexos"\n${2}    storePassword System.getenv("LEXOS_STORE_PASSWORD") ?: ""\n${2}    keyPassword System.getenv("LEXOS_KEY_PASSWORD") ?: ""\n${2}}\n${2}${3}/' "$BG"
        echo "    signingConfig release ajouté"
    fi

    if ! grep -q 'signingConfig signingConfigs.release' "$BG"; then
        perl -0pi -e 's/(release\s*\{\n\s*)minifyEnabled true/${1}signingConfig signingConfigs.release\n            minifyEnabled false/' "$BG"
        echo "    buildType release signé (minify off)"
    fi

    grep -q 'LEXOS_STORE_FILE' "$BG" && grep -q 'signingConfig signingConfigs.release' "$BG" \
        || { echo "    ERREUR : patch build.gradle incomplet." >&2; return 1; }
}

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

patch_build_gradle

echo "==> Overlay LexOS Pro appliqué avec succès."
