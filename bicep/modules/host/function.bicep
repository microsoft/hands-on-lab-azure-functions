param planName string
param appName string
param location string = resourceGroup().location
param storageAccountName string
param deploymentStorageContainerName string
param applicationInsightsName string
param tags object = {}
param functionAppRuntime string = 'dotnet-isolated'
param functionAppRuntimeVersion string = '8.0'
param maximumInstanceCount int = 100
param instanceMemoryMB int = 2048
param appSettings array = []
param azdServiceName string

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource flexFuncPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: planName
  location: location
  tags: tags
  kind: 'functionapp'
  sku: {
    tier: 'FlexConsumption'
    name: 'FC1'
  }
  properties: {
    reserved: true
  }
}

resource flexFuncApp 'Microsoft.Web/sites@2023-12-01' = {
  name: appName
  location: location
  tags: union(tags, { 'azd-service-name': azdServiceName })
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: flexFuncPlan.id
    siteConfig: {
      appSettings: concat(
        appSettings,        
        [
          {
            name: 'AzureWebJobsStorage__accountName'
            value: storage.name
          }
          {
            name  : 'APPLICATIONINSIGHTS_AUTHENTICATION_STRING'
            value : 'Authorization=AAD'
          }
          {
            name  : 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            value : 'InstrumentationKey=${appInsights.properties.InstrumentationKey};IngestionEndpoint=https://${location}.in.applicationinsights.azure.com/;LiveEndpoint=https://${location}.livediagnostics.monitor.azure.com/'
          }
        ]
      )
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storage.properties.primaryEndpoints.blob}${deploymentStorageContainerName}'
          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: maximumInstanceCount
        instanceMemoryMB: instanceMemoryMB
      }
      runtime: {
        name: functionAppRuntime
        version: functionAppRuntimeVersion
      }
    }
  }
}

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-blob-data-owner
var storageBlobDataOwnerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')

// Allow access from function app to storage account using a managed identity
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storage.id, flexFuncApp.id, storageBlobDataOwnerRoleId)
  scope: storage
  properties: {
    roleDefinitionId: storageBlobDataOwnerRoleId
    principalId: flexFuncApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output id string = flexFuncApp.id
output name string = flexFuncApp.name
output principalId string = flexFuncApp.identity.principalId
