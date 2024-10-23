param cosmosDbAccountName string
param funcStdPrincipalId string
param funcDrblPrincipalId string
param userPrincipalId string
param userPrincipalType string
param storageAccountAudiosName string
param storageFuncDrblName string
param keyVaultName string
param appInsightsName string
param azureOpenAIName string

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/monitor#monitoring-metrics-publisher
var metricsPublisherRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-queue-data-contributor
var storageQueueDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '974c5e8b-45b9-4653-ba55-5f855dd0fb88')

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-account-contributor
var storageAccountContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab')

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-table-data-contributor
var storageTableDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-blob-data-owner
var storageBlobDataOwnerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-user
var keyVaultSecretsUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-openai-user
var cognitiveServicesOpenAIUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' existing = {
  name: cosmosDbAccountName
}

resource cosmosDbDataReader 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-05-15' = {
  parent: cosmosDbAccount
  name: '00000000-0000-0000-0000-000000000001'
  properties: {
    roleName: 'Cosmos DB Built-in Data Reader'
    type: 'BuiltInRole'
    assignableScopes: [
      cosmosDbAccount.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
        ]
        notDataActions: []
      }
    ]
  }
}

resource cosmosDbDataContributor 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-05-15' = {
  parent: cosmosDbAccount
  name: '00000000-0000-0000-0000-000000000002'
  properties: {
    roleName: 'Cosmos DB Built-in Data Contributor'
    type: 'BuiltInRole'
    assignableScopes: [
      cosmosDbAccount.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
  }
}


resource userCosmosDbReader 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  parent: cosmosDbAccount
  name: guid(cosmosDbAccount.id, cosmosDbDataReader.id, userPrincipalId)
  properties: {
    roleDefinitionId: cosmosDbDataReader.id
    principalId: userPrincipalId
    scope: cosmosDbAccount.id
  }
}

resource userCosmosDbContributor 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  parent: cosmosDbAccount
  name: guid(cosmosDbAccount.id, cosmosDbDataContributor.id, userPrincipalId)
  properties: {
    roleDefinitionId: cosmosDbDataContributor.id
    principalId: userPrincipalId
    scope: cosmosDbAccount.id
  }
}

resource funcStdCosmosDbReader 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  parent: cosmosDbAccount
  name: '51f03358-a4a2-b520-f424-1f6b236c26ba'
  properties: {
    roleDefinitionId: cosmosDbDataReader.id
    principalId: funcStdPrincipalId
    scope: cosmosDbAccount.id
  }
}

resource funcDrblCosmosDbContributor 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  parent: cosmosDbAccount
  name: '5e38f7ee-7651-6b27-ae5a-5eff3e14731b'
  properties: {
    roleDefinitionId: cosmosDbDataContributor.id
    principalId: funcDrblPrincipalId
    scope: cosmosDbAccount.id
  }
}

resource storageAccountAudios 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountAudiosName
}

resource storageAccountAudiosRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccountAudios.id, storageQueueDataContributorRoleId)
  scope: storageAccountAudios
  properties: {
    roleDefinitionId: storageQueueDataContributorRoleId
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource uploaderStorageAccountAudiosRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccountAudios.id, storageBlobDataOwnerRoleId, funcStdPrincipalId)
  scope: storageAccountAudios
  properties: {
    roleDefinitionId: storageBlobDataOwnerRoleId
    principalId: funcStdPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource processorStorageAccountAudiosRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccountAudios.id, storageBlobDataOwnerRoleId, funcDrblPrincipalId)
  scope: storageAccountAudios
  properties: {
    roleDefinitionId: storageBlobDataOwnerRoleId
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource userStorageAccountAudiosRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccountAudios.id, storageBlobDataOwnerRoleId, userPrincipalId)
  scope: storageAccountAudios
  properties: {
    roleDefinitionId: storageBlobDataOwnerRoleId
    principalId: userPrincipalId
    principalType: userPrincipalType
  }
}

resource storageFuncDrbl 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageFuncDrblName
}

resource storageAccountContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageFuncDrbl.id, storageAccountContributorRoleId)
  scope: storageFuncDrbl
  properties: {
    roleDefinitionId: storageAccountContributorRoleId
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource storageAccountRoleQueueDataContributorFuncStdAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageFuncDrbl.id, storageQueueDataContributorRoleId)
  scope: storageFuncDrbl
  properties: {
    roleDefinitionId: storageQueueDataContributorRoleId
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource storageAccountRoleTableDataContributorFuncDrblAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageFuncDrbl.id, storageTableDataContributorRoleId)
  scope: storageFuncDrbl
  properties: {
    roleDefinitionId: storageTableDataContributorRoleId
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
}

resource keyVaultSecretsUserFuncDrblAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(keyVault.id, keyVaultSecretsUserRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultSecretsUserRoleId
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource monitoringMetricsPublisherFuncStdAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appInsights.id, funcStdPrincipalId, metricsPublisherRoleId)
  scope: appInsights
  properties: {
    roleDefinitionId: metricsPublisherRoleId
    principalId: funcStdPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource monitoringMetricsPublisherFuncDrblAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appInsights.id, funcDrblPrincipalId, metricsPublisherRoleId)
  scope: appInsights
  properties: {
    roleDefinitionId: metricsPublisherRoleId
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource azureOpenAI 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' existing = {
  name: azureOpenAIName
}

resource cognitiveServicesOpenAIUserFuncDrblAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(azureOpenAI.id, cognitiveServicesOpenAIUserRoleId)
  scope: azureOpenAI
  properties: {
    roleDefinitionId: cognitiveServicesOpenAIUserRoleId
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}
