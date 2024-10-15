resource "azapi_resource" "func_std" {
  type                      = "Microsoft.Web/sites@2023-12-01"
  schema_validation_enabled = false
  location                  = azurerm_resource_group.this.location
  name                      = local.func_std_name
  parent_id                 = azurerm_resource_group.this.id
  tags                      = local.tags
  body = jsonencode({
    kind = "functionapp,linux",
    identity = {
      type : "SystemAssigned"
    }
    properties = {
      serverFarmId = azapi_resource.plan_func_std.id,
      functionAppConfig = {
        deployment = {
          storage = {
            type  = "blobContainer",
            value = "${azurerm_storage_account.func_std.primary_blob_endpoint}${local.function_deployment_package_container}",
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
            name  = "AzureWebJobsStorage__accountName",
            value = azurerm_storage_account.func_std.name
          },
          {
            name  = "AudioUploadStorage__serviceUri",
            value = format("https://%s.blob.core.windows.net", azurerm_storage_account.this.name)
          },
          {
            name  = "APPLICATIONINSIGHTS_AUTHENTICATION_STRING",
            value = "Authorization=AAD"
          },
          {
            name  = "APPLICATIONINSIGHTS_CONNECTION_STRING",
            value = format("InstrumentationKey=%s;IngestionEndpoint=https://%s.in.applicationinsights.azure.com/;LiveEndpoint=https://%s.livediagnostics.monitor.azure.com/", azurerm_application_insights.func_std.instrumentation_key, var.location, var.location)
          },
          {
            name  = "STORAGE_ACCOUNT_CONTAINER",
            value = local.storage_account_container_name
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
            name  = "ERROR_RATE",
            value = "0"
          },
          {
            name  = "LATENCY_IN_SECONDS",
            value = "0"
          }
        ]
      }
    }
  })
  depends_on = [
    azapi_resource.plan_func_std,
    azurerm_application_insights.func_std,
    azurerm_storage_account.func_std
  ]
}
