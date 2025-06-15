# Configuration des Secrets GitHub pour Azure

Ce guide décrit les étapes pour créer un **Service Principal Azure** et enregistrer les secrets nécessaires dans GitHub Actions, ainsi que la clé SSH utilisée par Ansible.

## 1. Création du Service Principal

Exécuter la commande suivante (remplacez `<subscription-id>` par l'ID de votre abonnement) :
```bash
az ad sp create-for-rbac \
  --name tp-cicd-sp \
  --role="Contributor" \
  --scopes="/subscriptions/<subscription-id>" \
  --sdk-auth
```
La sortie JSON ressemble à :
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```
Conservez soigneusement ce bloc : c'est la valeur du secret `AZURE_CREDENTIALS`.

## 2. Génération de la clé SSH
```bash
ssh-keygen -t rsa -b 4096 -C "tp-cicd" -f ~/.ssh/tp-cicd
```
* `tp-cicd` (clé privée) sera encodée et stockée dans le secret `SSH_PRIVATE_KEY` (base64 ou texte brut).
* `tp-cicd.pub` (clé publique) sera ajoutée aux utilisateurs ou aux VMs provisionnées via Terraform/Ansible.

## 3. Ajout des secrets dans GitHub
Aller dans **Settings → Secrets and variables → Actions** du dépôt :

| Nom du secret | Contenu | Utilisation |
|---------------|---------|-------------|
| `AZURE_CREDENTIALS` | Sortie JSON de la commande az ad sp | Auth Azure dans les workflows Terraform/Ansible |
| `SSH_PRIVATE_KEY` | Contenu de `~/.ssh/tp-cicd` | Connexion SSH Ansible / déploiement |
| `TF_BACKEND_RG` | Nom du Resource Group contenant le Storage Account de backend | Terraform init |
| `TF_BACKEND_STORAGE_ACCOUNT` | Nom du Storage Account | Terraform init |
| `TF_BACKEND_CONTAINER` | Nom du container Blob | Terraform init |
| `TF_BACKEND_KEY` | Nom du fichier state (ex. `tp-cicd.tfstate`) | Terraform init |

## 4. Exemple d'utilisation dans GitHub Actions
```yaml
name: terraform
on:
  pull_request:
    paths: ["terraform/**"]

jobs:
  terraform:
    runs-on: ubuntu-latest

    permissions:
      id-token: write # pour OIDC
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: |
          terraform -chdir=terraform init \
            -backend-config="resource_group_name=${{ secrets.TF_BACKEND_RG }}" \
            -backend-config="storage_account_name=${{ secrets.TF_BACKEND_STORAGE_ACCOUNT }}" \
            -backend-config="container_name=${{ secrets.TF_BACKEND_CONTAINER }}" \
            -backend-config="key=${{ secrets.TF_BACKEND_KEY }}"

      - name: Terraform Validate
        run: terraform -chdir=terraform validate -no-color

      - name: Terraform Plan
        run: terraform -chdir=terraform plan -no-color
```

---

> Après avoir ajouté ces secrets, la Phase 1 (Terraform) pourra être automatisée sans exposer de données sensibles. 
