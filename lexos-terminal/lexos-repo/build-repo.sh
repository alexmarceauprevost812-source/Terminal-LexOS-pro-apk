#!/usr/bin/env bash
# build-repo.sh — fabrique le dépôt apt LexOS (statique : à poser sur GitHub Pages ou Vercel).
#
#   ./build-repo.sh [--out DIR] [--prefix PREFIXE] [--version X.Y.Z]
#                   [--extra-debs DIR] [--lexos-assets DIR] [--sign ID_CLE_GPG]
#
#  --prefix       préfixe de l'app (défaut /data/data/com.lexos.terminal/files/usr)
#  --extra-debs   .deb déjà compilés POUR CE PRÉFIXE (nmap, git, openssh, python, curl, jq…), voir docs/DEPOT.md
#  --lexos-assets scripts LexOS à empaqueter (défaut ../../overlay/app/src/main/assets/lexos)
#  --sign         ID d'une clé GPG à TOI (déjà créée) : signe Release (InRelease + Release.gpg) et exporte lexos.gpg
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/site"; PREFIX="/data/data/com.lexos.terminal/files/usr"; VERSION="0.1.0"
EXTRA=""; ASSETS="$HERE/../../overlay/app/src/main/assets/lexos"; SIGN=""
while [ $# -gt 0 ]; do
  case "$1" in
    --out) OUT="$2"; shift 2 ;; --prefix) PREFIX="$2"; shift 2 ;; --version) VERSION="$2"; shift 2 ;;
    --extra-debs) EXTRA="$2"; shift 2 ;; --lexos-assets) ASSETS="$2"; shift 2 ;; --sign) SIGN="$2"; shift 2 ;;
    -h|--help) sed -n 2,12p "$0"; exit 0 ;;
    *) echo "option inconnue : $1" >&2; exit 1 ;;
  esac
done
for c in dpkg-deb dpkg-scanpackages gzip sha256sum; do command -v "$c" >/dev/null || { echo "manque : $c (sudo apt install dpkg-dev)" >&2; exit 1; }; done
printf '%s' "$VERSION" | grep -Eq '^[0-9][0-9A-Za-z.+~-]*$' || { echo "version invalide" >&2; exit 1; }
printf '%s' "$PREFIX" | grep -Eq '^/[A-Za-z0-9._/-]+$' || { echo "préfixe invalide" >&2; exit 1; }

WORK="$(mktemp -d)"; trap 'rm -rf -- "$WORK"' EXIT
rm -rf -- "$OUT"; POOL="$OUT/pool/main"; mkdir -p "$POOL"

# --- paquet lexos-core : lex, lexos-audit, lexos-root, lexfetch ------------------------------
P="$WORK/lexos-core"; mkdir -p "$P/DEBIAN" "$P$PREFIX/bin"
for f in "$HERE"/src/lexos-core/bin/*; do
  sed "s#@PREFIX@#$PREFIX#g" "$f" > "$P$PREFIX/bin/$(basename "$f")"; chmod 755 "$P$PREFIX/bin/$(basename "$f")"
done
cat > "$P/DEBIAN/control" <<EOF
Package: lexos-core
Version: $VERSION
Architecture: all
Maintainer: LexOS <noreply@lexos.invalid>
Depends: bash, curl, jq
Recommends: nmap
Section: utils
Priority: optional
Description: LexOS Terminal — lex (IA locale avec confirmation), menu d'audit, lexfetch, lexos-root (désactivé par défaut)
EOF
dpkg-deb --root-owner-group -Zgzip -b "$P" "$POOL/lexos-core_${VERSION}_all.deb" >/dev/null

# --- paquet lexos : scripts du menu LexOS (depuis overlay/…/assets/lexos) ------------------------
if [ -d "$ASSETS" ]; then
  P="$WORK/lexos"; mkdir -p "$P/DEBIAN" "$P$PREFIX/bin" "$P$PREFIX/share/lexos"
  for n in aide lexos lexos-menu lexos-couleurs lexos-ia lexos-kali kali catalogue lexos-facile lexos-partage \
           lexos-fichier lexos-bienvenue apprendre lexos-info lexos-serveur lexos-bureau; do
    [ -f "$ASSETS/$n" ] || { echo "script absent : $n" >&2; exit 1; }
    sed "s#/data/data/com\.termux/files/usr#$PREFIX#g" "$ASSETS/$n" > "$P$PREFIX/bin/$n"; chmod 755 "$P$PREFIX/bin/$n"
  done
  # lexos-update est volontairement exclu : il met à jour l'APK Termux d'origine ; ici on met à jour avec « pkg upgrade ».
  cp -r "$ASSETS"/lexos.sh "$ASSETS"/explique.sh "$ASSETS"/explications.txt "$ASSETS"/banner.txt "$ASSETS"/banner.png \
        "$ASSETS"/avatar.png "$ASSETS"/menu-gauche.png "$ASSETS"/lecons "$ASSETS"/config "$P$PREFIX/share/lexos/"
  grep -rl "com\.termux" "$P" >/dev/null 2>&1 && { echo "ERREUR : 'com.termux' subsiste dans le paquet lexos :" >&2; grep -rn "com\.termux" "$P" | head >&2; exit 1; }
  cat > "$P/DEBIAN/postinst" <<EOF
#!$PREFIX/bin/sh
# Copie les ressources dans ~/.lexos sans écraser les fichiers de l'utilisateur.
[ -n "\${HOME:-}" ] || exit 0
mkdir -p "\$HOME/.lexos" || exit 0
cp -rn "$PREFIX/share/lexos/." "\$HOME/.lexos/" 2>/dev/null || true
exit 0
EOF
  chmod 755 "$P/DEBIAN/postinst"
  cat > "$P/DEBIAN/control" <<EOF
Package: lexos
Version: $VERSION
Architecture: all
Maintainer: LexOS <noreply@lexos.invalid>
Depends: lexos-core, bash, curl, jq
Recommends: lexos-audit-tools
Section: utils
Priority: optional
Description: Menu LexOS (accueil, catalogue, apprendre, IA locale, partage, bureau à distance…)
EOF
  dpkg-deb --root-owner-group -Zgzip -b "$P" "$POOL/lexos_${VERSION}_all.deb" >/dev/null
else
  echo "(scripts LexOS introuvables dans $ASSETS : paquet « lexos » ignoré)" >&2
fi

# --- méta-paquet : les outils d'audit (compilés à part pour ce préfixe) -----------------------
P="$WORK/lexos-audit-tools"; mkdir -p "$P/DEBIAN"
cat > "$P/DEBIAN/control" <<EOF
Package: lexos-audit-tools
Version: $VERSION
Architecture: all
Maintainer: LexOS <noreply@lexos.invalid>
Depends: lexos-core, nmap, python, git, openssh, curl, jq
Section: utils
Priority: optional
Description: Outils d'audit LexOS : nmap, python (sqlmap via pip), git, ssh. Sans root, usage légal seulement.
EOF
dpkg-deb --root-owner-group -Zgzip -b "$P" "$POOL/lexos-audit-tools_${VERSION}_all.deb" >/dev/null

# --- .deb compilés pour ce préfixe (fournis par toi) ------------------------------------------
if [ -n "$EXTRA" ]; then
  n=0; for d in "$EXTRA"/*.deb; do [ -f "$d" ] || continue; cp -- "$d" "$POOL/"; n=$((n+1)); done
  echo "→ $n .deb supplémentaires copiés depuis $EXTRA"
fi

# --- index apt ------------------------------------------------------------------------------
DIST="$OUT/dists/stable"; BIN="$DIST/main/binary-aarch64"; mkdir -p "$BIN"
( cd "$OUT" && dpkg-scanpackages -a aarch64 pool/main /dev/null > "$BIN/Packages" 2>/dev/null )
gzip -9 -k -f "$BIN/Packages"
{
  echo "Origin: LexOS"; echo "Label: LexOS Terminal"; echo "Suite: stable"; echo "Codename: stable"
  echo "Date: $(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S UTC')"
  echo "Architectures: aarch64"; echo "Components: main"
  echo "SHA256:"
  ( cd "$DIST" && for f in main/binary-aarch64/Packages main/binary-aarch64/Packages.gz; do
      printf ' %s %s %s\n' "$(sha256sum "$f" | cut -d' ' -f1)" "$(stat -c %s "$f")" "$f"; done )
} > "$DIST/Release"
if [ -n "$SIGN" ]; then
  gpg --batch --yes --default-key "$SIGN" --clearsign -o "$DIST/InRelease" "$DIST/Release"
  gpg --batch --yes --default-key "$SIGN" -abs -o "$DIST/Release.gpg" "$DIST/Release"
  gpg --batch --yes --export "$SIGN" > "$OUT/lexos.gpg"
  echo "→ dépôt signé (clé $SIGN), clé publique : $OUT/lexos.gpg"
else
  echo "⚠ dépôt NON signé : apt refusera de s'en servir sans [trusted=yes] (déconseillé). Utilise --sign."
fi
echo "→ dépôt prêt : $OUT"; ls -1 "$POOL"
