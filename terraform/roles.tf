resource "azurerm_role_assignment" "this" {
  count                = var.user_id != "" ? 1 : 0
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = var.user_id
}

resource "azurerm_role_assignment" "website_contributor_standard_function" {
  count                = var.create_managed_identity ? 1 : 0
  scope                = azurerm_linux_function_app.standard.id
  role_definition_name = "Website Contributor"
  principal_id         = azurerm_user_assigned_identity.standard_function[0].principal_id
}

data "azurerm_cosmosdb_sql_role_definition" "cosmos_db_contributor_standard_function" {
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  role_definition_id  = "00000000-0000-0000-0000-000000000002"
}

resource "random_uuid" "cosmos_db_contributor_uuid" {}

resource "azurerm_cosmosdb_sql_role_assignment" "cosmos_db_contributor_standard_function" {
  name                = random_uuid.cosmos_db_contributor_uuid.result
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.cosmos_db_contributor_standard_function.id
  principal_id        = azurerm_linux_function_app.standard.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.this.id
}
