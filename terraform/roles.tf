# Role to deploy the Azure Function with a managed identity using GitHub Actions.
resource "azurerm_role_assignment" "func_std_website_contributor" {
  scope                = data.azurerm_linux_function_app.func_std.id
  role_definition_name = "Website Contributor"
  principal_id         = azurerm_user_assigned_identity.func_std.principal_id
}

resource "random_uuid" "cosmos_db_contributor_uuid" {}

resource "azurerm_cosmosdb_sql_role_assignment" "func_std_cosmos_db_contributor" {
  name                = random_uuid.cosmos_db_contributor_uuid.result
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.func_std_cosmos_db_contributor.id
  principal_id        = data.azurerm_linux_function_app.func_std.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.this.id
}

resource "azurerm_role_assignment" "func_drbl_azure_openai_user" {
  scope                = azurerm_cognitive_account.open_ai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_std_audio_storage_data_owner" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_linux_function_app.func_std.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_drbl_audio_storage_blob_data_owner" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_drbl_audio_storage_queue_data_contributor" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_std_deployment_storage_blob_data_owner" {
  scope                = azurerm_storage_account.func_std.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_linux_function_app.func_std.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_drbl_deployment_storage_blob_data_owner" {
  scope                = azurerm_storage_account.func_drbl.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_drbl_storage_contributor" {
  scope                = azurerm_storage_account.func_drbl.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_drbl_storage_queue_data_contributor" {
  scope                = azurerm_storage_account.func_drbl.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_drbl_storage_table_data_contributor" {
  scope                = azurerm_storage_account.func_drbl.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id
}
