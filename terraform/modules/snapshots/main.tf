# Backup vault
resource "azurerm_recovery_services_vault" "vault" {
  name                = "${var.prefix}-rsv"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  soft_delete_enabled = true
}

# Backup policy (Daily, retention 7 days)
resource "azurerm_backup_policy_vm" "policy" {
  name                = "${var.prefix}-daily-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

# Protect the VM with the backup policy
resource "azurerm_backup_protected_vm" "protected" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = var.vm_id
  backup_policy_id    = azurerm_backup_policy_vm.policy.id
} 