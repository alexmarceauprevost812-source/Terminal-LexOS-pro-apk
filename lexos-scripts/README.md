# lexos-scripts

Sauvegarde des scripts runtime du projet **Terminal LexOS Pro** (reskin de Termux).
Ce dossier sert de copie versionnée des scripts et configs qui vivent sur le
téléphone Android/Termux. Il ne s'exécute pas tel quel : c'est une archive pour
restaurer ou réinstaller l'environnement.

## Arborescence

| Dossier ici            | Emplacement réel sur le téléphone        | Contenu                                    |
|------------------------|------------------------------------------|--------------------------------------------|
| `home-bin/`            | `~/bin/`                                  | Scripts utilisateur modifiés               |
| `prefix-bin/`          | `$PREFIX/bin/` (Termux)                   | Scripts créés + ponts vers outils Kali     |
| `config/`              | `~/`, `~/.lexos/`, `~/.termux/`, Kali     | Fichiers de configuration                  |

## Fichiers attendus

### `home-bin/` (depuis `~/bin/`)
- `lexos` — routeur principal (cas `outils|catalogue|tools`, `modeles|modele|model`)
- `aide` — agent IA (`__extract_cmd` blindé, `SYSTEM_AGENT`, spinner 🥷, fin en cyan)

### `prefix-bin/` (depuis `$PREFIX/bin/`)
- `kali` — lance Kali NetHunter (install si absent, `kali -r` = root, DNS auto 8.8.8.8, thème .bashrc)
- `catalogue` — menu `dialog` (thème noir/orange) des outils de sécu par catégorie
- `lexos-modeles` — sélecteur de modèles IA (Ollama + .gguf partagés), écrit `LEXAI_MODEL`
- `lexos-outils` — raccourci vers `catalogue`
- Ponts vers outils Kali (chacun `exec kali -r <outil>`) :
  `sqlmap` `msfconsole` `metasploit` `hydra` `nikto` `wpscan` `dirbuster`
  `gobuster` `nuclei` `masscan` `ettercap` `reaver` `wifite` `searchsploit`
  `medusa` `commix` `wafw00f` `dnsrecon` `theHarvester`

### `config/`
- `termux.bashrc` — `~/.bashrc` (PROMPT_COMMAND, invite LexOS cadre orange 208 / texte rouge 196)
- `dialogrc` — `~/.lexos/dialogrc` (thème dialog noir/orange)
- `lexos.config` — `~/.lexos/config` (`LEXAI_MODEL` actif)
- `kali-user.bashrc` — `~/kali-arm64/home/kali/.bashrc` (invite Kali user vert lime + bleu)
- `kali-root.bashrc` — `~/kali-arm64/root/.bashrc` (invite Kali root vert néon + rouge)
- `termux.properties` — `~/.termux/` (font-size + jaune remappé en orange)

## Restaurer sur le téléphone

```bash
cp lexos-scripts/home-bin/*     ~/bin/
cp lexos-scripts/prefix-bin/*   $PREFIX/bin/
chmod +x ~/bin/* $PREFIX/bin/*
# puis replacer les configs à la main selon le tableau ci-dessus
```

### `assets/`
- `menu-gauche.png` — icône (512x512, capuche noir/orange) pour ouvrir le menu de gauche / header du catalogue

### Header du catalogue
- `prefix-bin/lexos-header` — affiche `menu-gauche.png` en header via `chafa` (fallback ASCII).
  Ajouter en haut du script `catalogue` :
  ```bash
  lexos-header "CATALOGUE OUTILS"
  ```

### `app-design/` — sources de l'app visuelle (canevas de design)
- `Main.dc.html` — maquette « LEXOS-PRO » (téléphone) : header + bouton icône (menu gauche) + tiroir SYSTÈME (bureau à distance)
- `LexOS.dc.html` — maquette « LexOS IA » (nouveau modèle) : modes IA, commandes, menu gauche, bureau à distance
- `canvas.json` — index du canevas (positions des maquettes)

Ces fichiers sont les sources de l'artifact de design LEXOS. L'icône du menu est
dans `assets/menu-gauche.png`.

### `reference/` — documents de référence
- `couleurs-commandes-lexos-term.xlsx` — table officielle emoji / commande / couleur / code hex
  du terminal LEXOS. Les codes correspondent à ceux codés dans `app-design/`.

### Thème terminal + animations (couche d'affichage)
- `prefix-bin/couleurs.sh` — **source unique** de toutes les couleurs (ANSI 24 bits) +
  fonctions d'animation : `lexos_banner`, `lexos_spinner`, `lexos_bar`, `lexos_download`,
  `lexos_update`, `lexos_thinking`, `lexos_lines`, `lexos_gamer`, `lexos_cmd_color`,
  `lexos_mode_color`, `lexos_hex`, `lexos_reset`. À sourcer dans lexos/aide/catalogue.
  Démo : `couleurs.sh demo`.
- `config/termux.colors.properties` — thème Termux noir mat (→ `~/.termux/colors.properties`,
  puis `termux-reload-settings`).
- `reference/MISES-A-JOUR-TERMINAL-LEXOS.md` — cahier des charges du reskin terminal.
