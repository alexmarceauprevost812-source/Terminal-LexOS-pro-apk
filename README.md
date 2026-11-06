# Terminal LexOS Pro

Un reskin de [Termux](https://termux.dev) pour Android : terminal Linux habillé LexOS
(noir, orange néon), avec un menu d'accueil, une IA locale intégrée, et des ponts vers
les outils d'audit déjà installés dans Kali NetHunter.

## Installation (dans Termux)

```bash
pkg install -y git && \
git clone -b ccr-290bfce8-4waano \
  https://github.com/alexmarceauprevost812-source/Terminal-LexOS-pro-apk && \
bash Terminal-LexOS-pro-apk/lexos-scripts/install.sh
```

Ensuite, tape `lexos` pour démarrer. `install.sh` ne touche pas au moteur Termux —
c'est une couche d'affichage et de scripts par-dessus.

## Menu LexOS

| # | Option | Description |
|---|--------|--------------|
| 1 | 💬 Parler à l'IA | Assistant de commandes — modes `/codex` `/chat` `/auto` `/agent` |
| 2 | 🛠️ Outils d'audit (Kali) | Catalogue des outils de sécurité (NetHunter) |
| 3 | 🧩 Modèles IA | Choisir le modèle local (Ollama ou `.gguf`) |
| 4 | 🎨 Couleurs | Démo du thème LexOS |
| 5 | 🔄 Mise à jour | Met à jour les scripts et l'appli |
| 6 | 🤖 Installer / démarrer l'IA | Configure le moteur IA local (llama.cpp) |
| 7 | 💬 IA Commande | Mode facile pour débutants — discute, n'exécute jamais rien |
| 0 | ⌨️ Mode libre | Terminal normal |

## IA locale

L'IA tourne entièrement sur le téléphone (llama.cpp ou Ollama) — aucune donnée envoyée
dans le cloud.

- `lexos parler` — mode complet : l'IA peut proposer et, selon le mode choisi, exécuter
  des commandes (confirmation demandée pour tout ce qui est sensible).
- `lexos debutant` — IA Commande, mode facile : conversation seulement, aucune commande
  n'est jamais exécutée.

## Outils d'audit (Kali NetHunter)

`lexos outils` ouvre un catalogue de ponts vers des outils de sécurité déjà installés
côté Kali NetHunter (scan, audit web, etc.).

⚠️ **Usage réservé à tes propres appareils/réseaux, ou à des cibles pour lesquelles tu
as une autorisation explicite.**

## Structure du dépôt

Le détail des scripts, de l'arborescence (`home-bin/`, `prefix-bin/`, `config/`, …) et
de la procédure de restauration est dans
[`lexos-scripts/README.md`](lexos-scripts/README.md).
