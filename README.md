# ⚜ LexOS Terminal Android — APK indépendante

Dépôt : https://github.com/alexmarceauprevost812-source/Terminal-LexOS-pro-apk

## Version 0.1 : terminal Android natif

- Application LexOS Terminal, package ca.lexos.terminal (séparé de com.termux et CodexLocal).
- Vrai moteur Termux terminal-emulator et terminal-view, avec pseudo-terminal PTY.
- Shell local Android : /system/bin/sh, sans root.
- Écran français bleu nuit/noir, barre de saisie visible au-dessus du clavier Samsung.
- Boutons Nouveau, Ctrl+C, Tab, Échap, flèches, Copier et Coller.
- Application indépendante avant toute intégration future dans CodexLocal.

La v0.1 n'embarque PAS pkg/apt, les paquets Linux Termux, SSH ni les modèles IA : elle fournit le shell Android local. Le bootstrap Termux a un préfixe compilé dans ses binaires : le rebaptiser ne suffit pas, il faudrait le reconstruire pour ca.lexos.terminal. Nous évitons ainsi de casser une installation Termux déjà présente.

## Télécharger la compilation de test

Ouvrir Actions → LexOS Terminal - Android APK test → dernière exécution réussie → artefact LexOS-Terminal-Android-debug.

L'archive contient app-debug.apk et SHA256SUMS, si la compilation est réussie. Ne pas confondre une compilation réussie avec un test validé sur S25 Ultra.

IMPORTANT : les APK debug GitHub peuvent avoir des clés de signature différentes d'une compilation à l'autre. La mise à jour sans réinstallation n'est donc pas garantie avant une clé stable en secrets GitHub. Aucun mécanisme de mises à jour intégrées n'est encore fourni.

## Construire sur LexOS Linux

Préparer Git, JDK 17, Gradle 9.2.1, SDK Android API 36, NDK 29.0.14206865.

    bash scripts/fetch-termux-engine.sh
    python3 tests/check_project.py
    gradle :app:assembleDebug

APK : app/build/outputs/apk/debug/app-debug.apk

## Code source et licences

Le moteur Termux provient de https://github.com/termux/termux-app à la révision 8629e632fcb95da272221be327db653fb24befe9, récupérée avant compilation par scripts/fetch-termux-engine.sh.

Termux/termux-app est distribué sous GPL-3.0-only avec exceptions et notices en amont. Les bibliothèques terminal-view et terminal-emulator incluent des contributions Apache-2.0. Les nouveaux fichiers LexOS sont publiés sous GPL-3.0-only. Toute distribution d'APK doit rendre le code source correspondant accessible et conserver les notices.

Le dossier prototype/ archive le travail préparatoire depuis LexOS Pro ; il n'est pas utilisé par l'APK indépendante.

## Prochaines étapes

1. Vérifier la compilation GitHub et l'exécution réelle sur Samsung S25 Ultra.
2. Ajouter SSH sécurisé avec Tailscale vers LexOS Pro.
3. Sessions multiples, gestion de fichiers, personnalisation des touches.
4. Clé de signature stable et mise à jour APK.
5. Intégration réutilisable du terminal dans CodexLocal.
