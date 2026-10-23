# Signature de l'APK LexOS Pro

Pour qu'une mise à jour s'installe **par-dessus** l'app existante (sans « Appli
non installée »), **tous les builds doivent être signés avec la même clé** et le
**versionCode doit augmenter**. Ce dépôt gère ça automatiquement via GitHub
Actions et une clé stockée dans les **Secrets** du dépôt.

## 1. Créer la clé de release (UNE seule fois, sur un PC avec Java)

```bash
keytool -genkeypair -v \
  -keystore lexos-release.keystore \
  -alias lexos \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=LexOS Pro, O=LexOS, C=CA" \
  -storepass TON_MOT_DE_PASSE_STORE \
  -keypass  TON_MOT_DE_PASSE_KEY
```

> ⚠️ **Garde `lexos-release.keystore` et les deux mots de passe en lieu sûr.**
> Si tu les perds, tu ne pourras plus publier de mise à jour : il faudra
> désinstaller puis réinstaller l'app sur chaque téléphone.

Puis encode la clé en base64 (c'est ce qu'on met dans le secret) :

```bash
base64 -w0 lexos-release.keystore    # Linux
# ou, sur macOS :
base64 -i lexos-release.keystore
```

Copie toute la ligne produite.

### Depuis Windows (PowerShell)

Si ta clé est déjà sur un PC Windows, ouvre **PowerShell** dans le dossier du
keystore :

```powershell
# 1) Encoder la clé en base64 (va dans LEXOS_KEYSTORE_B64)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("lexos-release.keystore")) | Set-Clipboard
#   -> la valeur est copiée dans le presse-papier, colle-la dans le secret.
#   (ou, sans presse-papier :)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("lexos-release.keystore")) > keystore.b64.txt

# 2) Retrouver l'alias et vérifier la clé (keytool est fourni avec Java/Android Studio)
keytool -list -v -keystore lexos-release.keystore
#   -> cherche la ligne « Alias name: ... » = LEXOS_KEY_ALIAS
```

> 💡 Si c'est la clé qui a **déjà signé l'app installée sur ton téléphone**,
> une fois les secrets en place les mises à jour s'installeront **sans
> désinstaller** (même signature). Si c'est une **nouvelle** clé, il faudra
> désinstaller l'app une fois (étape 5).

## 2. Créer les Secrets GitHub

Dépôt → **Settings → Secrets and variables → Actions → New repository secret**.
Crée ces quatre secrets :

| Nom du secret            | Valeur                                            |
|--------------------------|---------------------------------------------------|
| `LEXOS_KEYSTORE_B64`     | la sortie base64 de l'étape 1                     |
| `LEXOS_KEYSTORE_PASSWORD`| le mot de passe du **store** (`-storepass`)       |
| `LEXOS_KEY_ALIAS`        | `lexos` (ou l'alias choisi avec `-alias`)         |
| `LEXOS_KEY_PASSWORD`     | le mot de passe de la **clé** (`-keypass`)        |

Une fois ces secrets en place, chaque push sur `claude` (ou un *Run workflow*
manuel) compile un APK **signé release** et le publie dans la Release `latest`.

Sans les secrets, le workflow compile quand même (build *debug*) mais affiche un
avertissement : ce build n'a pas la clé stable, à n'utiliser que pour tester.

## 3. versionCode

Le workflow fixe automatiquement :

- `versionCode = 10000 + numéro de build` → **augmente à chaque build**, donc
  Android accepte toujours la mise à jour (jamais un « downgrade »).
- `versionName = 0.118.<numéro de build>`.

Rien à faire de ton côté.

## 4. APK produit

`assembleRelease` avec `TERMUX_SPLIT_APKS_FOR_RELEASE_BUILDS=0` → **un seul APK
universel** (fonctionne sur arm64-v8a et les autres ABI). C'est lui qui est
publié sous le nom `LexOS-Pro.apk`.

## 5. À faire UNE fois sur le téléphone (passage à la nouvelle clé)

L'app déjà installée est signée avec une **autre** clé (ancien build / clé debug
/ vrai Termux). Android refuse de la remplacer par un APK signé différemment, d'où
« Appli non installée ». La première fois seulement :

1. **Sauvegarde** ce qui compte (tes scripts sont déjà sur GitHub).
2. **Désinstalle** l'app : Paramètres Android → Applications → **LexOS Pro**
   (paquet `com.termux`) → Désinstaller.
   - Si un **vrai Termux** (F-Droid / Play Store) est aussi installé, désinstalle-le
     aussi : il a le même paquet `com.termux` et bloque l'installation.
3. **Installe** le nouvel APK signé : `lexos maj`, ou télécharge `LexOS-Pro.apk`
   depuis la Release `latest` du dépôt et ouvre-le.
4. ✅ Désormais, toutes les mises à jour s'installent **par-dessus**, sans
   désinstaller (même clé + versionCode qui monte).
