# Clés de signature LexOS Pro

## Release (recommandé) — clé dans les Secrets

Les builds officiels sont signés avec une **clé release stable** stockée dans les
**Secrets GitHub** du dépôt (jamais commitée). C'est ce qui permet aux mises à
jour de s'installer par-dessus sans « Appli non installée ».

👉 Voir **[`SIGNING.md`](../SIGNING.md)** : comment créer la clé, la liste des
secrets (`LEXOS_KEYSTORE_B64`, `LEXOS_KEYSTORE_PASSWORD`, `LEXOS_KEY_ALIAS`,
`LEXOS_KEY_PASSWORD`) et les étapes à faire une fois sur le téléphone.

Le workflow `build-apk.yml` décode le keystore depuis le secret, fixe un
`versionCode` qui monte à chaque build, et compile `assembleRelease` signé.

## `lexos-debug.keystore` — repli uniquement

`lexos-debug.keystore` (mot de passe `android`, alias `androiddebugkey`) reste
dans le dépôt **seulement comme repli** pour les builds de test / forks **sans
secrets configurés**. Dans ce cas le workflow compile un build *debug* et
l'indique par un avertissement.

Ce n'est **pas** la clé des mises à jour officielles : dès que les secrets sont
en place, c'est la clé release (des Secrets) qui est utilisée.
