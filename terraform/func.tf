resource "azurerm_linux_function_app" "standard" {
  name                = format("func-std-%s", local.resource_suffix_kebabcase)
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  storage_account_name       = azurerm_storage_account.func_std.name
  storage_account_access_key = azurerm_storage_account.func_std.primary_access_key
  service_plan_id            = azurerm_service_plan.this.id

  tags = local.tags

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    STORAGE_ACCOUNT_CONTAINER               = local.storage_account_container_name
    STORAGE_ACCOUNT_CONNECTION_STRING       = azurerm_storage_account.this.primary_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY          = azurerm_application_insights.this.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING   = azurerm_application_insights.this.connection_string
    COSMOS_DB_DATABASE_NAME                 = local.cosmos_db_database_name
    COSMOS_DB_CONTAINER_ID                  = local.cosmos_db_container_name
    COSMOS_DB_CONNECTION_STRING             = azurerm_cosmosdb_account.this.primary_sql_connection_string
    ERROR_RATE                              = 0
    LATENCY_IN_SECONDS                      = 0
    TranscriptionsDatabase__accountEndpoint = azurerm_cosmosdb_account.this.endpoint
  }

  site_config {
    application_stack {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }
  }
}

resource "azurerm_linux_function_app" "durable" {
  name                = format("func-drbl-%s", local.resource_suffix_kebabcase)
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  storage_account_name       = azurerm_storage_account.func_drbl.name
  storage_account_access_key = azurerm_storage_account.func_drbl.primary_access_key
  service_plan_id            = azurerm_service_plan.this.id

  tags = local.tags

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    STORAGE_ACCOUNT_CONTAINER             = local.storage_account_container_name
    STORAGE_ACCOUNT_CONNECTION_STRING     = azurerm_storage_account.this.primary_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.this.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.this.connection_string
    SPEECH_TO_TEXT_ENDPOINT               = azurerm_cognitive_account.speech_to_text.endpoint
    SPEECH_TO_TEXT_API_KEY                = azurerm_cognitive_account.speech_to_text.primary_access_key
    COSMOS_DB_DATABASE_NAME               = local.cosmos_db_database_name
    COSMOS_DB_CONTAINER_ID                = local.cosmos_db_container_name
    COSMOS_DB_CONNECTION_STRING           = azurerm_cosmosdb_account.this.primary_sql_connection_string
    AZURE_OPENAI_ENDPOINT                 = azurerm_cognitive_account.open_ai.endpoint
    CHAT_MODEL_DEPLOYMENT_NAME            = azurerm_cognitive_deployment.gpt_35_turbo.name
  }

  site_config {

    application_stack {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }
  }
}
