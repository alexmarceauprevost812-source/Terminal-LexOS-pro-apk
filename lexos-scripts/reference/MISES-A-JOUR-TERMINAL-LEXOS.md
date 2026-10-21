# Terminal LexOS Pro — mises à jour à appliquer

> À donner à Claude Code dans le projet **Terminal-LexOS-pro-apk** (reskin de Termux).
> Ces changements viennent de la maquette de design (canevas « Terminal LEXOS-PRO »).
> Le but : reproduire ce look et ces animations **dans le vrai terminal**, sans toucher au moteur Termux.

---

## 1. Thème au repos (quand rien ne roule)

Noir mat, texte blanc et gris, **aucune couleur ni lumière**.

| Élément | Couleur | Code hex | ANSI truecolor |
|---|---|---|---|
| Fond | Noir pur | `#000000` | `\033[48;2;0;0;0m` |
| Texte principal | Blanc | `#EDEDED` | `\033[38;2;237;237;237m` |
| Texte secondaire | Gris | `#A3A3A3` | `\033[38;2;163;163;163m` |
| Indications, aide | Gris foncé | `#7A7A7A` | `\033[38;2;122;122;122m` |

- Logo **LEXOS** en grosses lettres pixel **blanches** (plus de logo orange ni de contour jaune).
- Sous le logo : `TERMINAL PRO · IA locale · llama.cpp` en gris foncé.
- Invite : `toi ❯` en blanc, curseur bloc qui clignote.
- État affiché : `● PRÊT` en gris.

## 2. Couleurs par commande (seulement pendant qu'elle travaille)

Quand une commande roule, **sa couleur s'allume** (texte de sortie, invite, curseur, barre d'état).
Quand elle finit, on revient au thème noir/gris après environ 1,5 s.

| Emoji | Commandes | Couleur | Hex | ANSI truecolor |
|---|---|---|---|---|
| ⬇️ | `telecharger`, `wget`, `curl`, `git clone`, `pkg/apt/pip/npm install` | Violet | `#B46BFF` | `\033[38;2;180;107;255m` |
| 🔍 | `scan`, `nmap` | Cyan | `#22D3EE` | `\033[38;2;34;211;238m` |
| 📡 | `ping` | Bleu | `#4D8DFF` | `\033[38;2;77;141;255m` |
| 🔄 | `maj`, `update`, `upgrade` | Vert | `#39FF88` | `\033[38;2;57;255;136m` |
| 🔥 | `supprimer`, `rm`, `delete` | Orange | `#FF9F1C` | `\033[38;2;255;159;28m` |
| 📖 | `aide`, `help` | Jaune | `#FFD23F` | `\033[38;2;255;210;63m` |
| ❌ | commande inconnue / erreur | Rouge | `#FF4D6D` | `\033[38;2;255;77;109m` |
| 🌈 | `gamer`, `rgb` | Toutes en boucle (départ rose) | `#FF2BD6` | `\033[38;2;255;43;214m` |
| 🧹 | `effacer`, `clear` | Aucune (vide l'écran) | — | — |

## 3. Couleurs des modes IA

Le mode actif s'affiche dans sa couleur. Les autres restent gris.

| Emoji | Mode | Couleur | Hex | ANSI truecolor |
|---|---|---|---|---|
| 💬 | `/chat` | Turquoise | `#2DD4BF` | `\033[38;2;45;212;191m` |
| 🧠 | `/codex` | Bleu ciel | `#38BDF8` | `\033[38;2;56;189;248m` |
| ⚙️ | `/auto` | Rose | `#FB7185` | `\033[38;2;251;113;133m` |
| 🕵️ | `/agent` | Vert lime | `#A3E635` | `\033[38;2;163;230;53m` |
| 🧩 | `/model` | Magenta | `#E879F9` | `\033[38;2;232;121;249m` |
| 👋 | `/q` | Gris | `#A3A3A3` | `\033[38;2;163;163;163m` |

- Tout ce qui n'est pas une commande est envoyé à **lex** (l'IA).
- Les réponses s'affichent comme `lex ❯ …` dans la couleur du mode actif.

## 4. Animations

1. **Téléchargement (violet)** : remplacer la sortie brute de `curl` (les longues colonnes de chiffres) par une barre de progression sur une seule ligne, réécrite avec `\r` :
   ```
   ⬇️ modele.gguf  [██████████░░░░░░░░░░]  52%  · 5.8 Mo/s
   ```
   - Utiliser `curl -#` ou `curl --progress-bar`, ou lire la progression et dessiner la barre soi-même.
   - À la fin : `💜 modele.gguf téléchargé ✅`
2. **Mise à jour (vert)** : même barre de progression, en vert.
3. **Spinner pendant le travail** : afficher `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏` en boucle, dans la couleur de la commande, à côté de l'état (ex. `⠹ ⬇️ TÉLÉCHARGEMENT`).
4. **IA qui réfléchit** : afficher `lex ●○○ → ○●○ → ○○●` en boucle jusqu'à la réponse.
5. **Scan (cyan)** : les appareils trouvés apparaissent **un par un** (petit délai entre chaque ligne).
6. **Ping (bleu)** : une ligne de réponse à la fois.
7. **Mode gamer** : le logo et l'invite changent de couleur toutes les ~150 ms pendant ~4 s, puis `✨ GG ! 🏆`.
8. **Logo** : petit clignotement de vieil écran, très léger (optionnel).
9. **Retour au repos** : après chaque commande, on remet la couleur blanche/grise (`\033[0m` + les couleurs du thème).

## 5. Message de démarrage

```
Démarrage du moteur en arrière-plan…        (gris foncé)
🧠 IA prête ! Parle-lui directement.         (vert #39FF88)
Choisis un mode, ou tape « aide » 👇         (gris foncé)
```

## 6. Règles pour Claude Code

- **Ne pas toucher au moteur Termux** : seulement l'affichage (thème, couleurs, scripts de démarrage, prompt).
- Mettre toutes les couleurs dans **un seul fichier** (ex. `couleurs.sh` ou `theme.py`) pour pouvoir les changer facilement.
- Le thème de Termux (`~/.termux/colors.properties`) : `background=#000000`, `foreground=#EDEDED`, `cursor=#EDEDED`.
- Tester sur le téléphone que les emojis et les couleurs 24 bits s'affichent bien.

## 7. Fichiers de référence

- Canevas de design : https://claude.ai/code/artifact/e514dd40-3248-47c4-9e4d-d66be02ef11c
  - `Main.dc.html` → version noire de départ
  - `LexOS.dc.html` → nouveau modèle avec modes IA et invite `toi ❯`
- `couleurs-commandes-lexos-term.xlsx` → tableau des couleurs
