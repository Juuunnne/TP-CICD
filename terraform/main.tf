# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Network Module
module "network" {
  source              = "./modules/network"
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  vnet_cidr   = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
}

# Compute Module
module "compute" {
  source              = "./modules/compute"
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  subnet_id      = module.network.subnet_id
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key
  vm_size        = "Standard_B1ms"
}

# Storage Module
module "storage" {
  source              = "./modules/storage"
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
}

# IAM Module
module "iam" {
  source              = "./modules/iam"
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  principal_id = module.compute.vm_identity_id
}

# Monitoring Module
module "monitoring" {
  source              = "./modules/monitoring"
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  subnet_id      = module.network.subnet_id
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key
  vm_size        = "Standard_B2s"
}

# Snapshots Module
module "snapshots" {
  source              = "./modules/snapshots"
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  vm_id = module.compute.vm_id
}

# Outputs
output "vm_public_ip" {
  value = module.compute.public_ip
}

output "monitoring_public_ip" {
  value = module.monitoring.public_ip
}

output "snapshot_protected_vm_id" {
  value = module.snapshots.protected_vm_id
} 