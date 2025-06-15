# Monitoring Stack – Prometheus & Grafana

> Phase 4 du plan de mise en œuvre : choix, architecture et pré-conception des ressources pour l'observabilité.

---

## 🎯 Objectifs

1. Collecter les métriques système et applicatives de toutes les VM déployées par Terraform.
2. Visualiser en temps réel l'état de la plateforme (dashboards Grafana).
3. Mettre en place des alertes (Alertmanager) qui déclenchent des notifications (e-mail / Teams / Slack).
4. S'intégrer au pipeline CI/CD afin de valider le bon fonctionnement après chaque déploiement.

---

## 🛠️ Choix des outils

| Composant | Rôle | Version cible |
|-----------|------|---------------|
| **Prometheus** | Scraping & stockage des métriques TS | 2.52.0 |
| **Node Exporter** | Exporter de métriques système (VM) | 1.7.0 |
| **Grafana** | Visualisation & alertes UI | 10.x |
| **Alertmanager** | Gestion des notifications d'alerte | v0.27 |

Pourquoi ce stack ?
* Cloud-agnostic, open-source, mature.
* Large écosystème de dashboards prêts à l'emploi.
* Facile à déployer (binaries ou containers).

---

## 🏗️ Architecture cible (Azure)

```mermaid
flowchart TD
  subgraph RG[Resource Group "monitoring-rg"]
    VM[⛳ monitoring-vm (Ubuntu)]
    disk[(Managed Disk /data)]
    NSG[🔒 NSG monitoring-nsg]
  end
  VM -- port 9090 --> Internet
  VM -- port 3000 --> Internet
  VM -- scrape --> Nodes((App / DB / Other VMs))
```

1. **VM Linux (Standard_B2s)** hébergeant :
   * Prometheus (`/etc/prometheus`, données `/data/prometheus`)
   * Grafana (port 3000)
   * Alertmanager (port 9093)
2. **Managed disk** attaché en `/data` pour persistance.
3. **NSG** autorisant :
   * TCP 9090 → Prometheus UI
   * TCP 3000 → Grafana UI
   * TCP 9093 → Alertmanager (optionnel)
4. **DNS** : enregistrement `monitoring.<domain>` (non géré dans cette phase).

---

## 📦 Déploiement – Terraform

Un nouveau module `terraform/modules/monitoring` sera créé :
* `main.tf` : VM, disque, NSG, IP publique.
* `variables.tf` : `prefix`, `location`, `vm_size`, etc.
* `outputs.tf` : IP publique, ports exposés.

Le root `terraform/main.tf` instanciera ce module quand `var.enable_monitoring` = `true`.

---

## 🚀 Configuration – Ansible

Le rôle `monitoring` (créé en phase 2) sera enrichi :
* Installation binaries Prometheus, Node Exporter, Alertmanager.
* Services systemd.
* Déploiera des dashboards JSON dans Grafana via API.
* Gèrera les alert rules (`*.yml`) placées dans `monitoring/alert_rules/`.

---

## 🔔 Alertes initiales

| Nom | Expression | Seuil | Gravité |
|-----|------------|-------|---------|
| `HighCPU` | `avg by(instance)(rate(node_cpu_seconds_total{mode!="idle"}[5m])) > 0.8` | >80 % | warning |
| `InstanceDown` | `up == 0` | N/A | critical |

---

## 🗺️ Dashboards

Dashboards Grafana importés :
* **Node Exporter Full** (ID 1860).
* **Prometheus 2.0 Overview** (ID 3662).
* Dashboard custom « Application » (à créer plus tard).

---

## ⏭️ Prochaines étapes (Phase 4)

1. **Implémenter** le module Terraform `monitoring` + variables par défaut.
2. **Étendre** le rôle Ansible `monitoring` : installation et configuration des services.
3. **Ajouter** les alert rules et dashboards dans `monitoring/`.
4. **Mettre à jour** les workflows CI/CD pour :
   * Vérifier que le port 9090 répond après déploiement.
   * Exporter les artefacts dashboards comme snapshot GitHub.

---

> Une fois ces étapes terminées, la plateforme bénéficiera d'une observabilité de base prête à être enrichie. 