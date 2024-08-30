resource "azurerm_role_assignment" "this" {
  count                = var.user_id != "" ? 1 : 0
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = var.user_id
}

resource "azurerm_role_assignment" "website_contributor_standard_function" {
  count                = var.create_managed_identity ? 1 : 0
  scope                = data.azurerm_linux_function_app.func_std_wrapper.id
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
  principal_id        = data.azurerm_linux_function_app.func_std_wrapper.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.this.id
}

resource "azurerm_role_assignment" "azure_openai_user_durable_function" {
  scope                = azurerm_cognitive_account.open_ai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = data.azurerm_linux_function_app.func_drbl_wrapper.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_std_audio_storage_roleassignment" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_linux_function_app.func_std_wrapper.identity.0.principal_id
}

resource "azurerm_role_assignment" "func_drbl_audio_storage_blob_roleassignment" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_linux_function_app.func_drbl_wrapper.identity.0.principal_id
}

resource "azurerm_role_assignment" "func_drbl_audio_storage_queue_roleassignment" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_linux_function_app.func_drbl_wrapper.identity.0.principal_id
}

resource "azurerm_role_assignment" "func_std_deployment_storage_roleassignment" {
  scope                = azurerm_storage_account.func_std.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_linux_function_app.func_std_wrapper.identity.0.principal_id
}

resource "azurerm_role_assignment" "func_drbl_deployment_storage_roleassignment" {
  scope                = azurerm_storage_account.func_drbl.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_linux_function_app.func_drbl_wrapper.identity.0.principal_id
}

resource "azurerm_role_assignment" "func_drbl_storage_contributor" {
  scope                = azurerm_storage_account.func_drbl.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azurerm_linux_function_app.func_drbl_wrapper.identity.0.principal_id
}

resource "azurerm_role_assignment" "func_drbl_storage_queue_contributor" {
  scope                = azurerm_storage_account.func_drbl.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_linux_function_app.func_drbl_wrapper.identity.0.principal_id
}

resource "azurerm_role_assignment" "func_drbl_storage_table_contributor" {
  scope                = azurerm_storage_account.func_drbl.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = data.azurerm_linux_function_app.func_drbl_wrapper.identity.0.principal_id
}
