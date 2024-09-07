resource "azurerm_storage_account" "this" {
  name                            = format("st%s", local.resource_suffix_lowercase)
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  tags                            = local.tags
}

resource "azurerm_storage_container" "this" {
  name                  = local.storage_account_container_name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_account" "func_std" {
  name                            = format("stfstd%s", local.resource_suffix_lowercase)
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  tags                            = local.tags
}

resource "azurerm_storage_container" "func_std_deployment" {
  name                  = local.function_deployment_package_container
  storage_account_name  = azurerm_storage_account.func_std.name
  container_access_type = "private"
}

resource "azurerm_storage_account" "func_drbl" {
  name                            = format("stfdrbl%s", local.resource_suffix_lowercase)
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  tags                            = local.tags
}

resource "azurerm_storage_container" "func_drbl_deployment" {
  name                  = local.function_deployment_package_container
  storage_account_name  = azurerm_storage_account.func_drbl.name
  container_access_type = "private"
}
