# Construire le bootstrap de LexOS Terminal (aarch64)

> **Statut honnête : ces commandes n'ont PAS été exécutées.** L'environnement où ce fork a été préparé n'a ni
> Docker ni émulateur. Elles viennent de la lecture des scripts de `termux-packages` (commit `9cfc799`) :
> `scripts/build-bootstraps.sh`, `scripts/run-docker.sh`, `scripts/properties.sh`. À toi de les lancer sur ta machine Linux.

## Pourquoi c'est nécessaire

Le bootstrap (shell, `apt`, `coreutils`…) est compilé pour un préfixe fixe : `/data/data/<nom du paquet>/files/usr`.
Celui de Termux est pour `com.termux`. Sous `com.lexos.terminal`, le shell et `pkg install` **ne marchent pas** avec
l'archive officielle. Il faut donc recompiler le bootstrap avec le nouveau nom de paquet.

Le build Gradle du fork télécharge l'archive officielle si tu ne lui donnes rien : l'APK compile, mais n'est **pas utilisable**
(Gradle affiche un avertissement `LEXOS ATTENTION`).

## Ce qu'il faut

- Une machine Linux x86_64 (ou arm64) avec **Docker**, ~60 Go libres, une bonne connexion. Le build compile tout depuis les
  sources : prévois **beaucoup de temps** (durée non mesurée par moi).
- Droits Docker (`sudo` si besoin : `export TERMUX_DOCKER_USE_SUDO=1`).

## Commandes

```bash
# 1. Récupérer termux-packages au commit lu pour ce document
git clone https://github.com/termux/termux-packages.git
cd termux-packages
git checkout 9cfc799

# 2. Mettre le nouveau nom de paquet (la ligne est dans scripts/properties.sh)
sed -i 's|^TERMUX_APP__PACKAGE_NAME="com.termux"|TERMUX_APP__PACKAGE_NAME="com.lexos.terminal"|' scripts/properties.sh
grep -n '^TERMUX_APP__PACKAGE_NAME=' scripts/properties.sh     # doit afficher com.lexos.terminal
# NE PAS toucher TERMUX_REPO_APP__PACKAGE_NAME : il reste com.termux (dépôt officiel).

# 3. Nettoyer d'éventuels paquets déjà compilés pour com.termux (obligatoire si tu as déjà buildé avant)
./scripts/run-docker.sh ./clean.sh

# 4. Construire le bootstrap aarch64 (le A55 et le S25 Ultra sont en aarch64)
./scripts/run-docker.sh ./scripts/build-bootstraps.sh --architectures aarch64 &> build.log

# 5. Résultat : bootstrap-aarch64.zip à la racine de termux-packages
ls -l bootstrap-aarch64.zip
```

Pour inclure d'autres paquets directement dans le bootstrap : `--add openssh,git,python` (liste séparée par des virgules).
Pour le reste, ils s'installeront avec `pkg install` — voir l'étape 3 (dépôt LexOS).

## Vérifier l'archive avant de s'en servir

```bash
mkdir /tmp/bs && cd /tmp/bs && unzip -q ~/termux-packages/bootstrap-aarch64.zip
# Aucune référence à l'ancien préfixe ne doit rester (la commande ne doit RIEN afficher) :
grep -rl "/data/data/com.termux" . | head
# Et le nouveau doit y être :
grep -rl "/data/data/com.lexos.terminal" . | head -3
```

## Brancher l'archive sur l'app

```bash
mkdir -p ~/lexos-bootstrap && cp ~/termux-packages/bootstrap-aarch64.zip ~/lexos-bootstrap/
cd Terminal-LexOS-pro-apk/lexos-terminal
./gradlew assembleDebug -PlexosBootstrapDir=$HOME/lexos-bootstrap
# (ou : LEXOS_BOOTSTRAP_DIR=$HOME/lexos-bootstrap ./gradlew assembleDebug)
```

Seule l'archive aarch64 est obligatoire. Les autres architectures (arm, i686, x86_64) reçoivent une archive vide :
l'APK ne fonctionnera pas dessus. APK : `app/build/outputs/apk/debug/`.

## À vérifier sur le téléphone (rien de ceci n'est testé)

1. L'app s'installe à côté de Termux (id différent) et s'ouvre sans planter.
2. Premier lancement : l'installation du bootstrap se termine, un prompt `bash` apparaît.
3. `echo $PREFIX` → `/data/data/com.lexos.terminal/files/usr`.
4. `pkg update` puis `pkg install nano` (sans erreur de signature / de dépôt).
5. `python --version`, `git --version`, `ssh -V`.
6. Les couleurs : fond noir + curseur orange la nuit ; fond blanc le jour (si pas de `~/.termux/colors.properties`).
7. Balayage à deux doigts gauche/droite : change de session avec une courte animation.

## Points de vigilance

- **Dépôt de paquets.** Les paquets `.deb` officiels sont compilés pour `/data/data/com.termux/...` : après le bootstrap,
  `pkg install` depuis le dépôt officiel donnerait des binaires qui ne marchent pas. Il faut un dépôt **compilé pour
  `com.lexos.terminal`** (étape 3) et `sources.list` pointant dessus. Le bootstrap lui-même contient un `sources.list` :
  vérifie-le (`cat $PREFIX/etc/apt/sources.list`).
- **Longueur du préfixe.** `com.lexos.terminal` (18 car.) est plus long que `com.termux` (10 car.). Les chemins de shebang
  (limite ~127) et de sockets Unix (limite ~108) laissent de la marge, mais un paquet qui les rallonge beaucoup pourrait
  casser. Si tu vois des erreurs « path too long », un nom plus court est la solution (à décider **avant** de construire).
- **Licences.** Chaque paquet du bootstrap a sa licence (souvent GPL). Il faudra en sortir la liste et publier les sources
  correspondantes (voir `LEXOS-LICENCES.md`). Pas encore fait.
