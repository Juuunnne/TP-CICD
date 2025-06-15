a. Présentation du projeC
O Contexte : brève description de l’API et de l’application mobile<
O Technologies utilisées.

## Versioning

Ce projet suit la convention **Semantic Versioning (SemVer)** : `MAJOR.MINOR.PATCH`.

* **MAJOR** : changements incompatibles.
* **MINOR** : fonctionnalités rétro-compatibles.
* **PATCH** : correctifs mineurs.

Un script d’assistance est disponible :
```bash
./scripts/bump_version.sh [major|minor|patch]
```
Il met à jour le fichier `VERSION`, crée un commit `chore(release): vX.Y.Z` et applique le tag Git correspondant.
