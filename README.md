# TP-CICD – Projet Démonstrateur DevOps

## Présentation du projet 🇫🇷

### Contexte
Ce démonstrateur a pour but de **provisionner automatiquement** :
1. L’infrastructure Azure (réseau, VM, stockage…).
2. Le déploiement de l’API back-end conteneurisée (futur couplage à une app mobile).
3. Les chaînes CI/CD, les sauvegardes et, à terme, l’observabilité.

### Technologies utilisées
| Domaine | Outils |
|---------|--------|
| IaC | Terraform 1.6 (provider `azurerm`) |
| Config / Deploy | Ansible 9 + dynamic inventory Azure |
| CI/CD | GitHub Actions (workflows YAML) |
| Conteneurisation | Docker, GHCR |
| Backup | Recovery Services Vault (Azure Backup) |
| Observabilité (phase 4) | Prometheus, Grafana |

---

## 📁 Arborescence

| Dossier | Rôle |
|---------|------|
| `terraform/` | Infrastructure as Code (Azure) : modules **network**, **compute**, **storage**, **iam** |
| `ansible/` | Gestion de configuration / déploiement applicatif |
| `api/` | Code de l’API + `Dockerfile` pour l’image conteneur |
| `monitoring/` | Manifests / docs pour la stack Observabilité (phase 4) |
| `scripts/` | Outils divers (ex. bump de version) |
| `docs/` | Additional documentation |
| `snapshots/` | Backup & rollback : module Terraform + script [HOWTOROLLBACK.md](snapshots/HOWTOROLLBACK.md) |
| `.github/workflows/` | Workflows CI/CD GitHub Actions |

---

## 🔑 Prérequis & Secrets

1. **Azure** : créer une *Service Principal* puis ajouter le JSON dans le secret `AZURE_CREDENTIALS`.
2. **GitHub Container Registry (GHCR)** : pas de secret dédié, on utilise `GITHUB_TOKEN`.
3. *(Facultatif)* autres secrets : backend Terraform, clés SSH, etc.

---

## 🏗️  Phase 1 – Infrastructure (Terraform)

* Modules déclaratifs dans `terraform/modules/*`.
* Backend distant configuré via `terraform/backend.tf`.
* Lint & plan automatisés par `.github/workflows/terraform.yml`.

---

## 🛠️  Phase 2 – Configuration (Ansible)

* **Inventaire dynamique** Azure : `ansible/inventory/azure_rm.yml` (plugin `azure_rm`).
* **Rôles** : `app`, `db`, `monitoring` (variables par défaut + tâches idempotentes).
* **Tests** : Molecule + Docker pour chaque rôle (`ansible/roles/*/molecule`).
* **Qualité** : `.github/workflows/ansible-ci.yml` exécute `ansible-lint` puis `molecule test`.

---

## 🚀  Phase 3 – CI/CD

| Workflow | Description | Déclencheurs |
|----------|-------------|--------------|
| `ci-build.yml` | Build & push de l’image `api` sur GHCR | Push / PR sur `api/**` |
| `cd-dev.yml` | Déploiement continu sur *dev* (`develop`) via Ansible | Push sur `develop` / manuel |
| `cd-prod.yml` | Promotion *prod* (merge `main`, tag `v*.*.*`, release) | Push sur `main`, tag SemVer, release |

Branches :
* `feature/*` → PR vers `develop` (checks CI)
* `develop` → déploiement *dev*
* `main` + tag SemVer → déploiement *prod* & snapshot

---

## 📦  Versioning

Ce projet suit **Semantic Versioning (SemVer)**. Utilisez :
```bash
./scripts/bump_version.sh [major|minor|patch]
```
Le script met à jour `VERSION`, commit avec le message `chore(release): vX.Y.Z` puis tague la version.

---

## 🐳  Démarrer en local

```bash
# Provisionner l’infra (sandbox)
cd terraform
terraform init && terraform apply

# Déployer la conf
cd ../ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventory/azure_rm.yml site.yml

# Lancer l’API en local
cd ../api
docker build -t api:dev .
docker run -p 8000:8000 api:dev
```

---

## 🤝  Contribuer

1. Fork / feature branch
2. `pre-commit run --all-files` (optionnel)
3. PR vers `develop` : tous les workflows doivent passer ✅
4. Merge mainteneur.

---

## 📄  Licence

MIT © 2024 – Projet pédagogique.

## Stratégie Git : GitFlow simplifié

```
main ⟶─✔    ← tags SemVer / prod
        
 develop ────🚀 déploiement dev
      \_ feature/*  PR → develop
       \_ hotfix/*  PR → main
```

* **main** : branche de production, version taguée `vX.Y.Z` → déclenche `cd-prod.yml`.
* **develop** : intégration continue, toujours déployée en *dev* via `cd-dev.yml`.
* **feature/** : nouvelles features, merge via PR + review.
* **hotfix/** : correctifs urgents sur `main`, rebasés ensuite sur `develop`.

> Capture d’écran d’historique Git : à insérer *(ex. `git log --graph --oneline`)*

---

## Détail des jobs CI/CD GitHub Actions

| Workflow | Fichier | Jobs | Rôle |
|-----------|---------|------|------|
| Terraform | `.github/workflows/terraform.yml` | `terraform` | Format, init, validate, plan (CI IaC) |
| Build API | `.github/workflows/ci-build.yml`  | `build` | Docker buildx + push image sur GHCR |
| CD Dev    | `.github/workflows/cd-dev.yml`   | `deploy-dev` | Exécute Ansible sur env *dev* |
| CD Prod   | `.github/workflows/cd-prod.yml`  | `deploy-prod` | Déploiement Blue env prod après tag |
| Snapshots | `.github/workflows/verify-snapshot.yml` | `check-snapshot` | Vérifie qu’un backup < 24 h existe |

Chaque job est commenté directement dans son fichier YAML pour plus de lisibilité.
