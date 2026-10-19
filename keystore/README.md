# Clé de signature LexOS Pro

`lexos-debug.keystore` est une clé **debug stable** (mot de passe `android`,
alias `androiddebugkey`). Elle est **volontairement** dans le dépôt : ce n'est
pas un secret pour une clé de debug.

**Pourquoi ?** Pour que toutes les compilations aient la **même signature**.
Sans ça, chaque build aurait une signature différente et Android **refuserait**
d'installer une mise à jour par-dessus (il faudrait désinstaller à chaque fois).

Le build CI copie ce fichier dans `~/.android/debug.keystore` avant de compiler,
donc `assembleDebug` signe toujours avec cette même clé → `lexos-update` marche.
