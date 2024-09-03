data "azurerm_client_config" "current" {}

data "azurerm_linux_function_app" "func_std" {
  name                = local.func_std_name
  resource_group_name = azurerm_resource_group.this.name
  depends_on = [
    azapi_resource.func_std
  ]
}

data "azurerm_linux_function_app" "func_drbl" {
  name                = local.func_drbl_name
  resource_group_name = azurerm_resource_group.this.name
  depends_on = [
    azapi_resource.func_drbl
  ]
}

data "azurerm_function_app_host_keys" "func_drbl" {
  name                = local.func_drbl_name
  resource_group_name = azurerm_resource_group.this.name
  depends_on = [
    azapi_resource.func_drbl
  ]
}

data "azurerm_cosmosdb_sql_role_definition" "func_std_cosmos_db_contributor" {
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  role_definition_id  = "00000000-0000-0000-0000-000000000002"
}
