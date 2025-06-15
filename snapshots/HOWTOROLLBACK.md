# 🔄 HOW TO ROLLBACK / RESTAURER UN SNAPSHOT

Ce document décrit la procédure pour **restaurer la dernière sauvegarde** (snapshot) d’une machine virtuelle protégée par **Azure Backup** dans ce projet.

---

## 📦 Contexte

1. Le module Terraform `terraform/modules/snapshots` crée :
   - Un *Recovery Services Vault* (RSV) destiné aux sauvegardes.
   - Une **policy quotidienne** (rétention : 7 jours).
   - L’association (*backup protection*) entre le RSV et la VM provisionnée.
2. À chaque exécution du workflow _CD Prod_ (merge sur `main` + tag SemVer), une sauvegarde est vérifiée / déclenchée.
3. Le script `snapshots/scripts/restore_snapshot.sh` permet de restaurer **manuellement** le dernier point de récupération.

---

## ⚙️ Prérequis côté opérateur

- **Azure CLI ≥ 2.55** installé localement (ou via Cloud Shell).
- Droits RBAC pour *Restaurer* des ressources protégées dans le *Recovery Services Vault*.
- Les paramètres suivants :
  1. **Resource Group** où se trouve le RSV.
  2. **Nom du Vault** (suffixe `-rsv` si vous avez gardé la convention du module Terraform).
  3. **Nom de l’instance de sauvegarde** (*Backup Instance*) correspondant à la VM (habituellement son nom).

```bash
# Authentification (exemple)
az login                # À défaut : az login --service-principal -u <appId> -p <password> -t <tenant>
```

---

## 📝 Procédure de restauration

1. Ouvrez un terminal à la racine du projet.
2. Exécutez le script avec les trois arguments attendus :

```bash
./snapshots/scripts/restore_snapshot.sh <RESOURCE_GROUP> <VAULT_NAME> <BACKUP_INSTANCE_NAME>
```

Exemple concret :

```bash
./snapshots/scripts/restore_snapshot.sh rg-prod myapp-rsv myapp-vm
```

Le script :
- Récupère le **dernier point de récupération** disponible.
- Initialise une **restauration niveau élément** (item-level recovery) vers la VM cible.
- S’exécute en mode *no-wait* et affiche un message invitant à suivre la progression dans le portail Azure.

> 🔔 Selon la taille du disque, la restauration peut prendre plusieurs minutes.

---

## ❓ Questions fréquentes

| Question | Réponse |
|----------|---------|
| *Puis-je restaurer un snapshot spécifique (pas forcément le dernier) ?* | Oui : remplacez l’option `--query "[-1].name"` dans le script par la date/ID souhaité ou passez l’ID en variable d’environnement. |
| *Le script échoue avec une erreur d’autorisations.* | Vérifiez que votre identité possède le rôle **Backup Contributor** (ou supérieur) sur le RSV. |
| *Le dossier `rollback/` est vide, est-ce normal ?* | Oui. Le rollback est géré via ce script pour l’instant ; le dossier est réservé à une future automatisation (ex. Ansible playbook). |

---

## 🧹 Nettoyer les restaurations

Après validation du rollback, pensez à :
- Supprimer les disques/données temporaires créés par la restauration (*mounted disks* dans le portail).
- Mettre à jour les DNS ou groupes de sécurité si l’adresse IP de la VM a changé.

---

✨ **Félicitations** ! Vous savez maintenant comment revenir rapidement à un état stable grâce aux snapshots Azure Backup. Bon dépannage ! 