resource "azapi_resource" "func_drbl" {
  type                      = "Microsoft.Web/sites@2023-12-01"
  schema_validation_enabled = false
  location                  = azurerm_resource_group.this.location
  name                      = local.func_drbl_name
  parent_id                 = azurerm_resource_group.this.id
  tags                      = local.tags
  body = jsonencode({
    kind = "functionapp,linux",
    identity = {
      type : "SystemAssigned"
    }
    properties = {
      serverFarmId = azapi_resource.server_farm.id,
      functionAppConfig = {
        deployment = {
          storage = {
            type  = "blobContainer",
            value = "${azurerm_storage_account.func_drbl.primary_blob_endpoint}${local.function_deployment_package_container}",
            authentication = {
              type = "SystemAssignedIdentity"
            }
          }
        },
        scaleAndConcurrency = {
          maximumInstanceCount = 100,
          instanceMemoryMB     = 2048
        },
        runtime = {
          name    = "dotnet-isolated",
          version = "8.0"
        }
      },
      siteConfig = {
        appSettings = [
          {
            name  = "AzureWebJobsStorage",
            value = azurerm_storage_account.func_drbl.primary_connection_string
          },
          {
            name  = "AzureWebJobsStorage__accountName",
            value = azurerm_storage_account.func_drbl.name
          },
          {
            name  = "STORAGE_ACCOUNT_URL",
            value = format("https://%s.blob.core.windows.net", azurerm_storage_account.this.name)
          },
          {
            name  = "STORAGE_ACCOUNT_CONTAINER",
            value = local.storage_account_container_name
          },
          {
            name  = "STORAGE_ACCOUNT_EVENT_GRID__blobServiceUri",
            value = format("https://%s.blob.core.windows.net", azurerm_storage_account.this.name)
          },
          {
            name  = "STORAGE_ACCOUNT_EVENT_GRID__queueServiceUri",
            value = format("https://%s.queue.core.windows.net", azurerm_storage_account.this.name)
          },
          {
            name  = "APPLICATIONINSIGHTS_CONNECTION_STRING",
            value = azurerm_application_insights.this.connection_string
          },
          {
            name  = "SPEECH_TO_TEXT_ENDPOINT",
            value = azurerm_cognitive_account.speech_to_text.endpoint
          },
          {
            name  = "SPEECH_TO_TEXT_API_KEY",
            value = azurerm_cognitive_account.speech_to_text.primary_access_key
          },
          {
            name  = "COSMOS_DB_DATABASE_NAME",
            value = local.cosmos_db_database_name
          },
          {
            name  = "COSMOS_DB_CONTAINER_ID",
            value = local.cosmos_db_container_name
          },
          {
            name  = "COSMOS_DB__accountEndpoint",
            value = azurerm_cosmosdb_account.this.endpoint
          },
          {
            name  = "AZURE_OPENAI_ENDPOINT",
            value = azurerm_cognitive_account.open_ai.endpoint
          },
          # {
          #   name  = "CHAT_MODEL_DEPLOYMENT_NAME",
          #   value = azurerm_cognitive_deployment.gpt_35_turbo.name
          # }
        ]
      }
    }
  })
  depends_on = [
    azapi_resource.server_farm,
    azurerm_application_insights.this,
    azurerm_storage_account.func_drbl
  ]
}
