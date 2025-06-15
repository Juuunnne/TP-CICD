output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "vm_identity_id" {
  value = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
} 