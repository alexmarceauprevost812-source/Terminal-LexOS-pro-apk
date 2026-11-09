# Licences de LexOS Terminal (fork de Termux)

> Ceci est un **résumé de lecture**, pas un avis juridique. Il repose uniquement sur les fichiers
> de licence réellement présents dans `termux-app@8629e63`. Avant une distribution large ou
> commerciale, fais-le valider par un juriste (voir le point ⚠️ plus bas).

## 1. Ce que dit l'amont, module par module

| Partie | Licence | D'où ça vient |
|---|---|---|
| `app/` (l'application) | **GPLv3 uniquement** | `LICENSE.md` à la racine |
| `terminal-emulator/` et `terminal-view/` | **GPLv3 uniquement**, avec du code **Apache 2.0** repris de [Android-Terminal-Emulator](https://github.com/jackpal/Android-Terminal-Emulator) | `LICENSE.md` à la racine (section « Exceptions ») |
| `termux-shared/` | **MIT** … | `termux-shared/LICENSE.md` |
| └ `termux-shared/.../shared/termux/*` | … sauf : **GPLv3 uniquement** (et `TermuxConstants.java`, `TermuxPropertyConstants.java` restent **MIT**) | idem |
| └ `termux-shared/.../shared/file/filesystem/*` | … sauf : **GPLv2 uniquement avec exception « Classpath »** (code d'OpenJDK `libcore/ojluni`) | idem |
| └ `termux-shared/.../shared/shell/StreamGobbler.java` | … sauf : **Apache 2.0** (code de libsuperuser) | idem |

Ce que j'ai constaté en lisant le code (et qui limite la précision de ce tableau) :

- `terminal-emulator/` et `terminal-view/` **n'ont aucun fichier de licence à eux**. La seule source
  d'information est la phrase d'exception de la racine. **Un seul** fichier porte un en-tête Apache
  (`terminal-view/.../PopupWindowCompatGingerbread.java`). La frontière exacte « ce qui est Apache /
  ce qui est GPLv3 » n'est donc **pas documentée par l'amont**. Prudence : on traite l'ensemble comme
  GPLv3 et on conserve intactes toutes les mentions Apache.
- La plupart des sources Termux n'ont **aucun en-tête de droits d'auteur** (`app/` : 0 fichier sur 35 ;
  `terminal-emulator/` : 0 sur 37). La licence ne repose que sur les fichiers `LICENSE.md`.
- Des mentions de **tiers** existent dans quelques fichiers (Oracle, JavaPLT group at Rice University,
  The Android Open Source Project). **Ne jamais les supprimer ni les modifier.**

Les textes complets sont dans [`licenses/`](licenses/) : `GPL-3.0-only.txt`, `Apache-2.0.txt`, `MIT.txt`.
(L'amont ne les contient pas : il ne fait que renvoyer vers des liens. Pour distribuer, il faut les embarquer.)

## 2. Obligations pour distribuer l'APK en gardant LexOS open source

Résumé de la GPLv3 appliqué à ce fork :

1. **Fournir le code source complet** correspondant à l'APK distribué, sous GPLv3. Ce dépôt public suffit
   pour le code ; il faut aussi pouvoir retrouver ce que le build y ajoute (le **bootstrap**, voir plus bas).
   D'où le commit amont **épinglé** et les scripts de build versionnés.
2. **Conserver** les avis de droits d'auteur, les avis de licence et le **texte de la GPLv3** (dossier `licenses/`).
3. **Signaler tes modifications**, de façon visible, avec leur date. C'est fait par l'historique git et
   `UPSTREAM.md` (`git diff 2d9444b -- lexos-terminal/`).
4. **Aucune restriction en plus** : tu ne peux pas interdire la redistribution, ni mettre l'APK sous
   une licence propriétaire. Tu peux demander un prix pour tes copies, mais pas empêcher qu'on les partage.
5. **Ton propre code ajouté** à l'application (lié ou dérivé) doit être sous GPLv3 (ou une licence
   compatible, comme Apache 2.0 ou MIT : l'ensemble de l'APK reste alors sous GPLv3). Pour rester simple
   et open source : **GPLv3**.
6. **Parties Apache 2.0** : conserver les avis (et un éventuel `NOTICE`) et indiquer les changements.
   Apache 2.0 est compatible avec la GPLv3.
7. **Parties MIT** : conserver l'avis de droits d'auteur et le texte de permission.

## 3. Points d'attention

- ⚠️ **`shared/file/filesystem/*` est « GPLv2 uniquement + Classpath »**, alors que le reste de l'application
  est « GPLv3 uniquement ». Mélanger du GPLv2-seul et du GPLv3-seul dans un même programme est une zone
  d'incompatibilité connue. Termux l'embarque tel quel ; je n'ai **pas** d'avis juridique sur ce point.
  À faire valider avant une distribution commerciale.
- **Nom et logo** : la GPL ne donne aucun droit sur la marque « Termux ». Le fork doit porter un autre nom
  (c'est le cas : « LexOS Terminal ») et ne pas réutiliser l'icône de Termux. Je n'ai pas trouvé de
  politique de marque écrite dans l'arbre amont ; je ne peux donc pas t'en dire davantage.
- **Le bootstrap n'est pas dans ce dépôt.** Les paquets installés dans l'application (`bash`, `apt`,
  `coreutils`…) ont **chacun leur licence**, souvent GPL. Quand le bootstrap sera construit (voir
  `docs/BOOTSTRAP.md`), il faudra en sortir la liste des paquets et de leurs licences, et publier les
  sources correspondantes. **Pas encore fait.**
- **GPLv3 « Installation Information »** : cette exigence vise les appareils de consommation vendus
  avec le logiciel préinstallé, pas un APK téléchargeable. À revoir si tu préinstalles LexOS Terminal
  sur des appareils que tu vends.
