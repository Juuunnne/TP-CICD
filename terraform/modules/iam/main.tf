data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  name               = uuid()
  scope              = data.azurerm_subscription.current.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id       = var.principal_id
} 