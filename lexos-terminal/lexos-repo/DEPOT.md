# Dépôt apt LexOS + outils d'audit + `lex`

Étape 3. **Ce qui est testé ici** (Linux, sans téléphone) est séparé de **ce qui reste à faire/vérifier** plus bas.

## Ce que contient le dépôt

| Paquet | Contenu | Source |
|---|---|---|
| `lexos-core` | `lex` (IA locale → commande → **ta confirmation**), `lexos-audit` (menu d'audit), `lexos-root` (désactivé par défaut), `lexfetch` | `src/lexos-core/` |
| `lexos` | le menu LexOS : `lexos`, `lexos-menu`, `catalogue`, `apprendre`, `aide`, partage, bureau à distance… | `overlay/app/src/main/assets/lexos/` |
| `lexos-audit-tools` | méta-paquet : dépend de `nmap python git openssh curl jq` | — |
| `nmap`, `git`, `openssh`, `python`, `curl`, `jq` | **à compiler pour `com.lexos.terminal`** (voir ci-dessous) | termux-packages |

`nikto` n'existe pas dans Termux et n'est pas fourni (utilise `lexos kali`). `sqlmap` s'installe par `pip` depuis `lexos-audit`
(jamais sans ta confirmation).

## Pourquoi nmap, git… doivent être recompilés

Les `.deb` officiels de Termux sont compilés pour `/data/data/com.termux/files/usr`. Sous `com.lexos.terminal` ils ne
marchent pas. Même `termux-packages` que pour le bootstrap (voir `../docs/BOOTSTRAP.md`, mêmes étapes 1 à 3) :

```bash
cd termux-packages      # déjà modifié pour com.lexos.terminal
./scripts/run-docker.sh ./build-package.sh -a aarch64 nmap git openssh python libcurl jq
ls output/*.deb         # « curl » est un sous-paquet de libcurl : curl_*.deb apparaît ici
```

(Commande **non exécutée** par moi : pas de Docker ici.) Rassemble les `.deb` dans un dossier, par ex. `~/lexos-debs/`.

## Construire le dépôt

```bash
# Une seule fois : TA clé de signature. Garde la clé privée HORS de GitHub (sauf comme Secret, voir plus bas).
gpg --quick-gen-key "LexOS apt <toi@exemple.com>" ed25519 sign 2y
gpg --list-secret-keys --keyid-format long          # note l'empreinte

cd lexos-terminal/lexos-repo
./build-repo.sh --extra-debs ~/lexos-debs --sign <EMPREINTE>
# -> site/ : dists/stable/…, pool/main/*.deb, lexos.gpg
```

Sans `--sign`, apt refuse le dépôt : ne contourne pas avec `trusted=yes`.

## Publier (GitHub Pages ou Vercel)

`site/` est un dossier de fichiers statiques : n'importe quel hébergeur statique convient.
- **GitHub Pages** : `.github/workflows/lexos-depot.yml` (déclenchement manuel seulement) construit et publie. Il lit la clé
  dans le Secret `LEXOS_APT_GPG_KEY` (clé privée exportée : `gpg --armor --export-secret-keys <EMPREINTE>`) et l'empreinte dans
  `LEXOS_APT_GPG_ID`. **Non testé** (je ne peux pas lancer GitHub Actions avec Pages d'ici).
- **Vercel** : `vercel deploy site --prod` depuis ta machine.

## Côté téléphone (dans LexOS Terminal)

```bash
curl -fsSL https://TON-SITE/lexos.gpg -o $PREFIX/etc/apt/trusted.gpg.d/lexos.gpg   # clé publique
echo "deb [signed-by=$PREFIX/etc/apt/trusted.gpg.d/lexos.gpg] https://TON-SITE stable main" > $PREFIX/etc/apt/sources.list.d/lexos.list
pkg update && pkg install lexos lexos-audit-tools
```

Le mieux : mettre ces deux fichiers directement dans le bootstrap (voir `BOOTSTRAP.md`), pour que ce soit prêt au premier lancement.

## `lex`

```
lex quels fichiers prennent le plus de place ici
```
1. L'IA locale (llama.cpp sur `127.0.0.1:8080`, démarrée par `lexos ia`) propose **une** commande.
2. Elle est affichée. **Rien ne part** sans que tu tapes `oui` (réponse lue sur `/dev/tty` : un pipe ne peut pas répondre).
3. Sans terminal : affichée, jamais lancée. Commandes `sudo`/`su`, `rm -rf /`, `mkfs`, `curl … | sh`, `reboot`… : refusées.
   (liste simple, **pas une garantie** : relis toujours la commande.)
4. Journal : `~/.lexos/lex.log`.

## Menu d'audit `lexos-audit`

Sans root, `nmap -sT` seulement. Cibles privées (10/8, 172.16/12, 192.168/16, 127/8) directement ; toute autre cible exige de
taper `J'AI L'AUTORISATION`. Journal : `~/.lexos/audit.log`. Il propose d'installer ce qui manque (avec confirmation).

## Impossible sans root (je ne contourne pas)

- Scans SYN/UDP, détection d'OS (`-sS -sU -O`), raw sockets, sniffing : **impossibles** (le noyau Samsung ne les permet pas à une app).
- `proot`/chroot complet : peut planter (signal 11) sur ce noyau ; non utilisé par ce dépôt.
- `nmap -sn` sans root ne fait qu'un test TCP 80/443 : un appareil qui ferme ces ports peut ne pas apparaître.

## Root / Shizuku (optionnel, désactivé)

`lexos-root status | on root | on shizuku | off | run <commande>`. Désactivé tant que tu ne l'actives pas. Même activé,
chaque commande demande ton `oui`, et `lex` ne l'utilise **jamais**. `on root` exige un `su` (téléphone rooté) ; `on shizuku`
exige `rish` (export depuis l'app Shizuku). La logique est testée avec de faux `su`/`rish` ; **pas avec un vrai** téléphone rooté ni Shizuku.

## Testé / pas testé

Testé (Linux, `lexos-repo/tests/`) :
- `build-repo.sh` fabrique les 3 `.deb` ; avec une clé de TEST jetable, **le vrai `apt-get update` accepte le dépôt signé** (aarch64) et voit `lexos-core`.
- `lex` : 17 contrôles (oui/non/Entrée/réponse floue, 8 commandes dangereuses refusées, sans terminal, IA arrêtée, journal) avec fausse IA + vrai pty.
- `lexos-audit` : 53 contrôles (validation des cibles, injection d'options, phrase d'autorisation, jamais `-sS/-O/-A`).
- `lexos-root` : 11 contrôles avec faux `su`/`rish`.

Pas testé :
- Rien sur téléphone. Aucun `.deb` compilé (nmap, git…) : il faut Docker + termux-packages (voir plus haut).
- `pkg install lexos` de bout en bout, le `postinst`, les scripts du menu sous le nouveau préfixe.
- La qualité des commandes proposées par `lex` avec le petit modèle (0,5 Md de paramètres) : non mesurée.
- Le workflow GitHub Pages. Le vrai `su`, Shizuku.
- Licences des paquets compilés (GPL…) : liste et sources à publier, pas faits.
