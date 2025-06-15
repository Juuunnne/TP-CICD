#!/usr/bin/env bash
# Create Azure Resource Group, Storage Account and Blob Container for Terraform remote backend.
# Requires az CLI and authentication (az login or GitHub OIDC).

set -euo pipefail

# Default names
RESOURCE_GROUP="rg-tp-cicd-state"
STORAGE_ACCOUNT="sttpcicd"
CONTAINER="tfstate"
STATE_KEY="tp-cicd.tfstate"
LOCATION="westeurope"

usage() {
  echo "Usage: $0 [--rg <name>] [--sa <name>] [--container <name>] [--location <azure-region>]" >&2
  exit 1
}

# Parse args (optional overrides)
while [[ $# -gt 0 ]]; do
  case "$1" in
    --rg)
      RESOURCE_GROUP="$2"; shift 2 ;;
    --sa)
      STORAGE_ACCOUNT="$2"; shift 2 ;;
    --container)
      CONTAINER="$2"; shift 2 ;;
    --location)
      LOCATION="$2"; shift 2 ;;
    *) usage ;;
  esac
done

echo "Creating RG: $RESOURCE_GROUP (location: $LOCATION)"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

echo "Creating Storage Account: $STORAGE_ACCOUNT"
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false

STORAGE_KEY=$(az storage account keys list --account-name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --query "[0].value" -o tsv)

echo "Creating Container: $CONTAINER"
az storage container create --name "$CONTAINER" --account-name "$STORAGE_ACCOUNT" --account-key "$STORAGE_KEY"

echo "\nBackend ready! Please add the following variables/secrets to GitHub:"
echo "TF_BACKEND_RG=$RESOURCE_GROUP"
echo "TF_BACKEND_STORAGE_ACCOUNT=$STORAGE_ACCOUNT"
echo "TF_BACKEND_CONTAINER=$CONTAINER"
echo "TF_BACKEND_KEY=$STATE_KEY" 