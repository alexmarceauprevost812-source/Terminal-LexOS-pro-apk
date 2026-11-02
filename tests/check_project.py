#!/usr/bin/env python3
"""Tests de structure non destructifs sur les sources Android."""
from pathlib import Path
from xml.etree import ElementTree as ET
root = Path(__file__).resolve().parents[1]
app = (root / "app/build.gradle").read_text()
manifest = root / "app/src/main/AndroidManifest.xml"
activity = (root / "app/src/main/java/ca/lexos/terminal/MainActivity.java").read_text()
shell = (root / "scripts/fetch-termux-engine.sh").read_text()
assert "applicationId 'ca.lexos.terminal'" in app
assert '"/system/bin/sh"' in activity
assert "TerminalSession" in activity and "TerminalView" in activity
assert "SOFT_INPUT_ADJUST_RESIZE" in activity
assert "android:windowSoftInputMode=\"adjustResize\"" in manifest.read_text()
assert "termux/termux-app.git" in shell
assert "8629e632fcb95da272221be327db653fb24befe9" in shell
for p in ("app/src/main/AndroidManifest.xml", "app/src/main/res/values/strings.xml",
          "app/src/main/res/drawable/ic_lexos_terminal.xml"):
    ET.parse(root / p)
assert (root / "third_party/termux-app/LICENSE.md").is_file()
assert (root / "third_party/termux-app/terminal-view").is_dir()
assert (root / "third_party/termux-app/terminal-emulator").is_dir()
print("Tests LexOS Terminal OK : identite Android independante, Termux embarque en modules.")
