resource "random_uuid" "func_std_cosmos_db_contributor_uuid" {}
resource "random_uuid" "func_drbl_cosmos_db_contributor_uuid" {}

resource "azurerm_cosmosdb_sql_role_assignment" "func_std_cosmos_db_contributor" {
  name                = random_uuid.func_std_cosmos_db_contributor_uuid.result
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.cosmos_db_data_contributor.id
  principal_id        = data.azurerm_linux_function_app.func_std.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.this.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "func_drbl_cosmos_db_contributor" {
  name                = random_uuid.func_drbl_cosmos_db_contributor_uuid.result
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.cosmos_db_data_contributor.id
  principal_id        = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.this.id
}

resource "azurerm_role_assignment" "func_std_audio_storage_blob_data_owner" {
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

resource "azurerm_role_assignment" "func_drbl_key_vault_secrets_user" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_std_monitoring_metrics_publisher" {
  scope                = azurerm_application_insights.func_std.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = data.azurerm_linux_function_app.func_std.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_drbl_monitoring_metrics_publisher" {
  scope                = azurerm_application_insights.func_drbl.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_drbl_cognitive_services_openai_user" {
  scope                = azurerm_cognitive_account.open_ai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id
}

resource "azurerm_role_assignment" "user_key_vault_administrator" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "api_management_service_contributor" {
  scope                = azurerm_api_management.this.id
  role_definition_name = "API Management Service Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}