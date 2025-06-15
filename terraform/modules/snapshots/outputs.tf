output "vault_name" {
  value = azurerm_recovery_services_vault.vault.name
}

output "protected_vm_id" {
  value = azurerm_backup_protected_vm.protected.id
} 