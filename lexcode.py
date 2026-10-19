#!/usr/bin/env python3
"""LexCode — agent de code à IA locale pour le terminal (Termux / Linux).

Parle à un modèle .gguf servi par llama-server (llama.cpp), propose des
commandes et des fichiers, et les exécute après ta confirmation.
Aucune dépendance : seulement la bibliothèque standard de Python.

Usage :
    python lexcode.py          # demande confirmation avant chaque action
    python lexcode.py --auto   # exécute sans demander (prudence !)
"""
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request

API = os.environ.get("LEX_API", "http://127.0.0.1:8080/v1/chat/completions")
MAX_SORTIE = 4000      # caractères de sortie renvoyés au modèle
MAX_ETAPES = 8         # actions enchaînées max par demande
MAX_HISTO = 20         # messages gardés en mémoire (hors système)

ORANGE = "\033[38;5;208m"
GRIS = "\033[90m"
VERT = "\033[32m"
ROUGE = "\033[31m"
RESET = "\033[0m"

SYSTEME = """Tu es LexCode, un assistant de programmation qui travaille dans un terminal Linux (Termux).
Réponds en français, brièvement.

Pour exécuter une commande, écris-la dans un bloc :
```bash
commande
```

Pour créer ou remplacer un fichier, écris son contenu COMPLET ainsi :
```file:chemin/du/fichier
contenu
```

Pour lire un fichier, utilise un bloc bash avec cat.
Après chaque action tu recevras le résultat. Avance une étape à la fois.
Quand la tâche est terminée, dis-le simplement, sans bloc."""

BLOC = re.compile(r"```(bash|sh|file:[^\n]+)\n(.*?)```", re.DOTALL)

# Commandes jugées dangereuses : même en mode --auto, LexCode demande avant.
DANGER = re.compile(
    r"\brm\s+(-\w*[rf]|--recursive|--force)"   # rm -r, rm -rf, rm -f
    r"|\brm\s+.*(\*|~|\$HOME|/\s*$)"           # rm sur * ou le dossier perso
    r"|\bmv\s+(~|\$HOME)/?(\s|$)"              # déplacer le dossier perso
    r"|\b(mkfs|dd|shred|wipefs)\b"             # effacement de disque
    r"|>\s*/dev/"                              # écriture sur un périphérique
    r"|\bchmod\s+-R|\bchown\s+-R"              # permissions récursives
    r"|\b(reboot|shutdown|poweroff)\b"
    r"|\bpkg\s+(uninstall|remove)|\bapt\s+(remove|purge|autoremove)"
    r"|:\(\)\s*\{"                             # fork bomb
    r"|\b(curl|wget)\b.*\|\s*(ba)?sh"          # script internet exécuté direct
)


def est_dangereux(cmd):
    return bool(DANGER.search(cmd))


def demander_modele(messages):
    """Envoie la conversation au serveur local et affiche la réponse en direct."""
    corps = json.dumps({
        "messages": messages,
        "stream": True,
        "temperature": 0.2,
    }).encode()
    req = urllib.request.Request(API, corps, {"Content-Type": "application/json"})
    texte = ""
    with urllib.request.urlopen(req, timeout=900) as rep:
        for brut in rep:
            ligne = brut.decode("utf-8", "ignore").strip()
            if not ligne.startswith("data:"):
                continue
            donnees = ligne[5:].strip()
            if donnees == "[DONE]":
                break
            try:
                morceau = json.loads(donnees)["choices"][0]["delta"].get("content") or ""
            except (KeyError, IndexError, json.JSONDecodeError):
                continue
            texte += morceau
            print(morceau, end="", flush=True)
    print()
    return texte


def confirmer(question, auto, dangereux=False):
    if auto and not dangereux:
        print(f"{GRIS}[auto] {question}{RESET}")
        return True
    if dangereux:
        print(f"{ROUGE}⚠ Commande potentiellement dangereuse.{RESET}")
    try:
        rep = input(f"{ORANGE}? {question} [o/N] {RESET}").strip().lower()
    except (EOFError, KeyboardInterrupt):
        print()
        return False
    return rep in ("o", "oui", "y", "yes")


def executer_actions(texte, auto):
    resultats = []
    for genre, contenu in BLOC.findall(texte):
        if genre.startswith("file:"):
            chemin = os.path.expanduser(genre[5:].strip())
            # Écraser un fichier de config caché (.bashrc, .profile…) = dangereux
            risque = os.path.basename(chemin).startswith(".") and os.path.exists(chemin)
            if confirmer(f"Écrire le fichier {chemin} ?", auto, risque):
                try:
                    os.makedirs(os.path.dirname(chemin) or ".", exist_ok=True)
                    with open(chemin, "w", encoding="utf-8") as f:
                        f.write(contenu)
                    print(f"{VERT}✓ {chemin} écrit{RESET}")
                    resultats.append(f"Fichier {chemin} écrit ({len(contenu)} caractères).")
                except OSError as e:
                    print(f"{ROUGE}✗ {e}{RESET}")
                    resultats.append(f"Erreur en écrivant {chemin} : {e}")
            else:
                resultats.append(f"L'utilisateur a refusé d'écrire {chemin}.")
        else:
            cmd = contenu.strip()
            if not cmd:
                continue
            if confirmer(f"Exécuter : {cmd}", auto, est_dangereux(cmd)):
                try:
                    p = subprocess.run(cmd, shell=True, capture_output=True,
                                       text=True, timeout=300)
                    sortie = (p.stdout + p.stderr)[-MAX_SORTIE:] or "(aucune sortie)"
                    code = p.returncode
                except subprocess.TimeoutExpired:
                    sortie, code = "Délai dépassé (5 min).", -1
                couleur = VERT if code == 0 else ROUGE
                print(f"{GRIS}{sortie}{RESET}{couleur}[code {code}]{RESET}")
                resultats.append(f"$ {cmd}\n[code {code}]\n{sortie}")
            else:
                resultats.append(f"L'utilisateur a refusé d'exécuter : {cmd}")
    return resultats


def main():
    auto = "--auto" in sys.argv
    mode = "auto (demande seulement si dangereux)" if auto else "confirmation"
    print(f"{ORANGE}♛ LexCode{RESET} — IA locale · {GRIS}{API} · mode {mode}{RESET}")
    print(f"{GRIS}/reset efface la conversation · /q pour quitter{RESET}\n")

    messages = [{"role": "system", "content": SYSTEME}]

    while True:
        try:
            demande = input(f"{ORANGE}lex ❯ {RESET}").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break
        if not demande:
            continue
        if demande in ("/q", "/quitter", "exit"):
            break
        if demande == "/reset":
            messages = messages[:1]
            print(f"{GRIS}Conversation effacée.{RESET}")
            continue

        messages.append({"role": "user", "content": demande})

        for _ in range(MAX_ETAPES):
            messages = messages[:1] + messages[1:][-MAX_HISTO:]
            try:
                reponse = demander_modele(messages)
            except urllib.error.URLError:
                print(f"{ROUGE}Serveur IA injoignable. Lance d'abord llama-server "
                      f"(voir les instructions).{RESET}")
                break
            except KeyboardInterrupt:
                print(f"\n{GRIS}Interrompu.{RESET}")
                break
            messages.append({"role": "assistant", "content": reponse})
            resultats = executer_actions(reponse, auto)
            if not resultats:
                break
            messages.append({"role": "user",
                             "content": "Résultat :\n" + "\n\n".join(resultats)})


if __name__ == "__main__":
    main()
