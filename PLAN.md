# PLAN de Mise en Œuvre DevOps

Ce document décrit la feuille de route détaillée pour mener à bien les **8 missions** confiées. Chaque étape précise :
* Objectif
* Actions à réaliser
* Dossier concerné
* Dépendances (prérequis ou livrables d'autres missions)
* Livrables/critères de fin

---

## Vue d'ensemble des dépendances
1. **Terraform (Infra) ➜ Ansible (Config) ➜ CI/CD (Pipeline) ➜ Release & Versioning**
2. **Monitoring & Logs** dépendent de l'infrastructure et doivent être référencés dans Ansible puis validés via le pipeline.
3. **Snapshots & Rollback** dépendent des ressources Terraform et des workflows CI/CD pour être orchestrés automatiquement.
4. **Stratégie Git** encadre toutes les missions (branches, PR, tags).

Diagramme simplifié :
```
Terraform ➜ Ansible ➜ CI/CD ➜ Versioning
           ↘             ↘
            Monitoring    Snapshots & Rollback
```

---

## Phase 0 : Initialisation
| # | Action | Dossier | Dépendances | Livrable |
|---|---------|---------|-------------|----------|
|0.1|Définir les normes Git (branches *main*, *develop*, *feat/*, *fix/*), template PR/commit.|`/`|Aucune|`docs/git-strategy.md`|
|0.2|Choisir la convention de versionnement (SemVer) & automatisation via tags.|`/tags`|0.1|`scripts/bump_version.sh`, README section Versioning |
|0.3|Créer secrets nécessaires dans GitHub (cloud creds, SSH).|GitHub UI|Aucune|Secrets renseignés|

---

## Phase 1 : Infrastructure as Code (Terraform)
| # | Action | Dossier | Dépendances | Livrable |
|---|---------|---------|-------------|----------|
|1.1|Définir le *state backend* (remote, verrouillage).|`terraform/`|0.3|`terraform/backend.tf`|
|1.2|Modéliser modules : réseau, compute, storage, IAM.|`terraform/modules`|1.1|Modules + `main.tf`|
|1.3|Variables & workspace strategy (env-based).|`terraform/`|1.2|`variables.tf`, `env/`|
|1.4|CI Terraform : fmt, validate, plan.|`terraform/`|1.3|GitHub Action `terraform.yml`|
|1.5|Provisionnement automatique sur *dev* env.|Cloud|1.4|Infra *dev* opérationnelle|

---

## Phase 2 : Configuration Management (Ansible)
| # | Action | Dossier | Dépendances | Livrable |
|---|---------|---------|-------------|----------|
|2.1|Inventaire dynamique basé sur tags Terraform.|`ansible/inventory`|1.5|`inventory_aws_ec2.yml`|
|2.2|Rôles pour app, DB, monitoring agent.|`ansible/roles`|2.1|Rôles structurés|
|2.3|Playbooks idempotents + tests Molecule.|`ansible/`|2.2|`site.yml`, tests pass|
|2.4|Intégration Ansible dans pipeline CI.|`.github/workflows`|2.3|`ansible-ci.yml`|

---

## Phase 3 : Pipeline CI/CD (GitHub Actions)
| # | Action | Dossier | Dépendances | Livrable |
|---|---------|---------|-------------|----------|
|3.1|Workflow Build/Test → Docker image publish.|`api/`, `.github/workflows`|0.2|`ci-build.yml`, image sur registry|
|3.2|Déploiement continu sur *dev* via Ansible/Terraform outputs.|`.github/workflows`|3.1,2.3|`cd-dev.yml`|
|3.3|Promotion vers *prod* via PR Merge + tag.|`.github/workflows`|3.2|`cd-prod.yml`|

---

## Phase 4 : Monitoring & Logging
| # | Action | Dossier | Dépendances | Livrable |
|---|---------|---------|-------------|----------|
|4.1|Choisir stack (Prometheus-Grafana, ELK).|`monitoring/`|1.2|Design doc|
|4.2|Déployer via Terraform modules (SG, EBS).|`terraform/modules/monitoring`|4.1|Infra monitoring|
|4.3|Configurer agents via Ansible.|`ansible/roles/monitoring`|4.2|Logs visibles, métriques|
|4.4|Alertes + dashboards préconfigurés.|`monitoring/`|4.3|Dashboards Grafana, alert rules|

---

## Phase 5 : Snapshots & Sauvegarde d'état
| # | Action | Dossier | Dépendances | Livrable |
|---|---------|---------|-------------|----------|
|5.1|Activer snapshots automatiques volumes/DB.|`snapshots/terraform`|1.2|Policies snapshot|
|5.2|Script de restauration validé en staging.|`snapshots/scripts`|5.1|`restore_snapshot.sh` test OK|
|5.3|Intégrer check snapshot dans pipeline.|`.github/workflows`|5.2|Job `verify-snapshot`|

---

## Phase 6 : Rollback Stratégie
| # | Action | Dossier | Dépendances | Livrable |
|---|---------|---------|-------------|----------|
|6.1|Déploiement blue/green ou canary via Terraform.|`rollback/`|1.3,3.1|Infra double|
|6.2|Playbook rollback (switch DNS, ASG).|`rollback/`|6.1|`rollback.yml`|
|6.3|Job GitHub Action déclenchant rollback sur échec.|`.github/workflows`|6.2|`trigger-rollback.yml`|

---

## Phase 7 : Documentation & Validation Finale
| # | Action | Dossier | Dépendances | Livrable |
|---|---------|---------|-------------|----------|
|7.1|Documenter chaque composant (README par dossier).|All|Phases 1-6|Docs complètes|
|7.2|Run book d'exploitation & procédures d'urgence.|`docs/`|7.1|`runbook.md`|
|7.3|Audit sécurité & cost review.|Cloud, `/`|7.2|Rapport d'audit|

---

## Gouvernance Git
* Feature branch → PR vers `develop`, revue obligatoire
* `develop` auto-deploy sur *dev*
* Merge `develop` → `main` déclenche : tag SemVer, build, déploiement *prod*, snapshot

## Convention de Versionnement
* **MAJOR** : rupture API ou infra
* **MINOR** : nouvelle fonctionnalité rétro-compatible
* **PATCH** : correctif
* **vX.Y.Z** tagué sur `main`, auto-bump fichier VERSION

---

## Prochaine étape immédiate
Démarrer la **Phase 0** (normes Git & versionning) afin de sécuriser la base de travail avant l'écriture du code Terraform. 