# NOTICE — modifications LexOS Pro

LexOS Pro ne modifie **pas** le moteur de Termux. Il ajoute une couche
« interface » posée au moment de la compilation. Voici exactement ce qui est
ajouté ou changé par rapport à `termux/termux-app` :

## Ajouté
- `app/src/main/java/com/termux/app/LexosSetup.java` — installe au premier
  démarrage : l'assistant `aide`, le thème du terminal, l'invite colorée.
- `app/src/main/assets/lexos/*` — assistant IA `aide`, `lexos.sh` (invite +
  couleurs), `config`, `colors.properties` (thème du terminal).
- Icône et écran de démarrage LexOS (ressources `mipmap`/`drawable`).

## Modifié (couleurs / nom seulement)
- `app/src/main/res/values/colors.xml` et `themes.xml` — palette noir + orange.
- `app/src/main/res/values/strings.xml` — nom affiché « LexOS Pro ».
- `app/src/main/java/com/termux/app/TermuxInstaller.java` — 2 lignes ajoutées
  pour appeler `LexosSetup.run(...)` au démarrage.

## Inchangé
- Tout le reste : nom de package (`com.termux`), émulateur, bootstrap, apt,
  paquets. Les paquets Termux restent 100 % compatibles.
