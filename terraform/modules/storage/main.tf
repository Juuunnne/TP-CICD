resource "azurerm_storage_account" "app_sa" {
  name                     = "${var.prefix}sa${random_string.rand.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

resource "random_string" "rand" {
  length  = 4
  upper   = false
  special = false
} 