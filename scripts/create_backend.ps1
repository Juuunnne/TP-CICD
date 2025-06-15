<#
.SYNOPSIS
  Provisionne le backend Terraform sur Azure (Resource Group + Storage Account + Container).

.PARAMETER ResourceGroup
  Nom du Resource Group. Par défaut 'rg-tp-cicd-state'.

.PARAMETER StorageAccount
  Nom du Storage Account. Par défaut 'sttpcicd'.

.PARAMETER Container
  Nom du container Blob. Par défaut 'tfstate'.

.PARAMETER Location
  Région Azure. Par défaut 'westeurope'.

.EXAMPLE
  ./create_backend.ps1 -ResourceGroup rg-tp-cicd-state -StorageAccount sttpcicd -Container tfstate -Location westeurope
#>
param(
  [string]$ResourceGroup = "rg-tp-cicd-state",
  [string]$StorageAccount = "sttpcicd",
  [string]$Container = "tfstate",
  [string]$Location = "westeurope"
)

# Safe script settings
$ErrorActionPreference = "Stop"

Write-Host "Creating Resource Group: $ResourceGroup in $Location" -ForegroundColor Cyan
az group create --name $ResourceGroup --location $Location | Out-Null

Write-Host "Creating Storage Account: $StorageAccount" -ForegroundColor Cyan
az storage account create `
  --name $StorageAccount `
  --resource-group $ResourceGroup `
  --location $Location `
  --sku Standard_LRS `
  --kind StorageV2 `
  --allow-blob-public-access false | Out-Null

$storageKey = az storage account keys list --account-name $StorageAccount --resource-group $ResourceGroup --query "[0].value" -o tsv

Write-Host "Creating Container: $Container" -ForegroundColor Cyan
az storage container create `
  --name $Container `
  --account-name $StorageAccount `
  --account-key $storageKey | Out-Null

$stateKey = "tp-cicd.tfstate"

Write-Host "`nBackend ready! Add the following variables/secrets to GitHub:`n" -ForegroundColor Green
Write-Host "TF_BACKEND_RG=$ResourceGroup"
Write-Host "TF_BACKEND_STORAGE_ACCOUNT=$StorageAccount"
Write-Host "TF_BACKEND_CONTAINER=$Container"
Write-Host "TF_BACKEND_KEY=$stateKey" 