# LexOS Pro — Terminal 🟠⬛

Un terminal Android **basé sur le moteur de [Termux](https://github.com/termux/termux-app)**
(exactement le même : `apt`, `python`, `bash`, tous les paquets), avec une
**interface LexOS** : noir + orange, invite colorée, et un **assistant IA local**
qui te guide dans les commandes.

> **Même moteur, nouvelle peau.** Le dépôt ne contient que l'interface. À la
> compilation, GitHub récupère le vrai Termux (intact) et pose l'interface
> par-dessus. Résultat : rien à maintenir côté moteur.

---

## 📥 Obtenir l'APK (aucune installation d'outil requise)

1. Va dans l'onglet **Actions** du dépôt → ouvre le dernier build **« Build LexOS Pro APK »**.
2. En bas, section **Artifacts** → télécharge **`LexOS-Pro-APK`**.
   - Ou, plus simple : la **Release `latest`** (onglet *Releases*) contient
     toujours le dernier `LexOS-Pro-debug.apk` prêt à installer.
3. Sur le téléphone : ouvre l'APK, autorise **« installer depuis cette source »**, installe.

> C'est un APK *debug* (signé avec la clé de debug) : parfait pour tester.
> Pour une version signée « release », on ajoutera une clé plus tard.

Le build se relance tout seul à chaque `push` sur la branche `claude`, ou
manuellement (**Actions → Build LexOS Pro APK → Run workflow**).

---

## 🤖 L'assistant `aide`

Dans le terminal, demande une commande en français :

```
aide comment extraire un fichier zip
aide -e "tar -xzf archive.tar.gz"     # explique une commande
aide                                   # mode conversation
```

Il tourne sur une **IA locale**, au choix (configurable dans `~/.lexos/config`) :

- **Ollama** (par défaut) — modèles partagés :
  ```
  pkg install ollama && ollama serve        # dans un onglet
  ollama pull llama3.2
  ```
- **llama.cpp sur un `.gguf`** — pour réutiliser **le même modèle que CodexLocal**
  (zéro double téléchargement) :
  ```
  termux-setup-storage && pkg install llama-cpp
  # mets ton .gguf dans ~/storage/shared/Models/ (accessible aux 2 apps)
  # dans ~/.lexos/config : LEXAI_BACKEND="llama" + LEXAI_GGUF="...chemin..."
  aide --serve-gguf                          # dans un onglet
  ```

`aide --install-ia` affiche ces étapes à tout moment.

---

## 🔗 Compatibilité avec CodexLocal

- LexOS Pro garde le package `com.termux` ; CodexLocal a le sien → **les deux
  s'installent et tournent en même temps**, sans conflit.
- **Partage des modèles** : place tes `.gguf` dans le **stockage partagé**
  (`~/storage/shared/Models/`) et pointe les deux apps dessus. Un seul fichier,
  pas de téléchargement en double.

---

## 🎨 Personnaliser

Tout est dans `overlay/` (copié tel quel sur Termux au build) :

| Quoi | Fichier |
|------|---------|
| Couleurs de l'app (barre, touches, tiroir) | `overlay/app/src/main/res/values/colors.xml` + `themes.xml` |
| Couleurs **du terminal** | `overlay/app/src/main/assets/lexos/colors.properties` |
| Invite + alias + couleurs des commandes | `overlay/app/src/main/assets/lexos/lexos.sh` |
| Nom de l'app | `build-config.env` → `LEXOS_APP_NAME` |
| Icône / écran de démarrage | `overlay/app/src/main/res/mipmap-*` et `drawable/` |
| Version de Termux utilisée | `build-config.env` → `TERMUX_REF` |

Tester localement l'overlay (sans builder) :
```
git clone https://github.com/termux/termux-app
scripts/apply-overlay.sh termux-app
```

---

## 🗺️ À venir

- [ ] **Fond d'écran visible (~30 %)** derrière le terminal — nécessite un patch
      du moteur de rendu (Termux force un fond opaque). Prévu comme patch dédié,
      à valider sur appareil.
- [ ] **Logo Marceau** (couronne) en icône + écran de démarrage — en attente du
      fichier logo (PNG, idéalement fond transparent).
- [ ] Police assortie et version « release » signée.

---

## 📄 Licence

GPLv3 only — voir [`LICENSE.md`](LICENSE.md) et [`NOTICE.md`](NOTICE.md).
Travail dérivé de Termux © ses contributeurs. Merci à eux. 🙏
