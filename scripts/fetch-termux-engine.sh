#!/usr/bin/env bash
# Source authentique Termux, revision fixe pour des builds reproductibles.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/third_party/termux-app"
SHA="8629e632fcb95da272221be327db653fb24befe9"
if [ -e "$DEST" ]; then
  if [ "$(git -C "$DEST" rev-parse HEAD 2>/dev/null)" = "$SHA" ]; then
    echo "Moteur Termux present au commit $SHA"; exit 0
  fi
  echo "Refus d'ecraser un autre clone : $DEST" >&2; exit 1
fi
mkdir -p "$(dirname "$DEST")"
git init -q "$DEST"
git -C "$DEST" remote add origin https://github.com/termux/termux-app.git
git -C "$DEST" fetch --depth=1 origin "$SHA"
git -C "$DEST" checkout --detach FETCH_HEAD
[ "$(git -C "$DEST" rev-parse HEAD)" = "$SHA" ] || exit 1
[ -f "$DEST/LICENSE.md" ] || { echo "Licence amont absente" >&2; exit 1; }
echo "Moteur Termux pret : $SHA"
