# TP-CICD – Projet Démonstrateur DevOps

Ce dépôt illustre la mise en place progressive d’une chaîne **Infrastructure → Configuration → CI/CD → Monitoring** sur Azure, automatisée par **Terraform**, **Ansible** et **GitHub Actions**.

> Objectif pédagogique : disposer d’un socle reproductible que l’on peut enrichir mission après mission (cf. `PLAN.md`).

---

## 📁 Arborescence

| Dossier | Rôle |
|---------|------|
| `terraform/` | Infrastructure as Code (Azure) : modules **network**, **compute**, **storage**, **iam** |
| `ansible/` | Gestion de configuration / déploiement applicatif |
| `api/` | Code de l’API + `Dockerfile` pour l’image conteneur |
| `monitoring/` | Manifests / docs pour la stack Observabilité (phase 4) |
| `scripts/` | Outils divers (ex. bump de version) |
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
