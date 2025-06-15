# Stratégie Git

Ce référentiel adopte une stratégie Git inspirée de **GitFlow** tout en restant légère :

## Branches principales

| Nom | Rôle |
|-----|------|
| `main` | Historique stable en production. Chaque fusion déclenche un déploiement *prod* et le tag SemVer correspondant. |
| `develop` | Intégration continue. Dernière version stable acceptée sur l'environnement *dev*. |

## Branches de travail

| Préfixe | Exemples | Usage |
|---------|----------|-------|
| `feat/` | `feat/auth-sso` | Nouvelles fonctionnalités |
| `fix/`  | `fix/login-redirect` | Correctifs de bug |
| `chore/`| `chore/upgrade-node` | Tâches techniques sans impact fonctionnel |
| `hotfix/`| `hotfix/payment-timeout` | Correctifs urgents directement depuis `main` |

## Flux standard
1. Créer une branche depuis `develop` (ou `main` pour hotfix).
2. Commits en suivant la convention *Conventional Commits* (voir plus bas).
3. Ouvrir une **Pull Request** vers la branche cible :
   * `feat/*`, `fix/*`, `chore/*` ⟶ PR vers `develop`.
   * `hotfix/*` ⟶ PR vers `main` puis fusion manuelle de `main` dans `develop`.
4. Obligation : revue + CI verte avant merge.

## Politique de fusion
* **Squash & Merge** pour garder un historique propre.
* Le message de squash doit respecter la convention.

## Conventions de Commit (Conventional Commits)

Format :
```
type(scope): description

[body]
[footer]
```
`type` ∈ `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`.

Exemple :
```
feat(api): add JWT authentication
```

## Template de Pull Request
Voici un exemple de template (`.github/pull_request_template.md`) :
```
### Description

...

### Checklist
- [ ] Code compilé/testé
- [ ] Tests unitaires passés
- [ ] Documentation mise à jour
- [ ] Label approprié appliqué
```

## Cycle de Release
1. Merge `develop` → `main` (via PR). 
2. Le workflow CI :
   * Bump de version via script `scripts/bump_version.sh <niveau>`.
   * Tag `vX.Y.Z` créé automatiquement.
   * Déploiement production.
   * Snapshots/sauvegarde.

---

*Fichier maintenu par `docs/git-strategy.md`* 