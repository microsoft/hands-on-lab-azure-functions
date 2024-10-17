param cosmosDbAccountName string
param funcStdPrincipalId string
param funcDrblPrincipalId string
param storageAccountAudiosName string
param storageFuncDrblName string
param keyVaultName string
param appInsightFuncStdName string
param appInsightFuncDrblName string
param azureOpenAIName string

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' existing = {
  name: cosmosDbAccountName
}

resource databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_00000000_0000_0000_0000_000000000001 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-05-15' = {
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

resource funcStdCosmosDbContributor 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  parent: cosmosDbAccount
  name: '51f03358-a4a2-b520-f424-1f6b236c26ba'
  properties: {
    roleDefinitionId: cosmosDbDataContributor.id
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

var storageQueueDataContributorRoleFuncStdDefinitionId = '974c5e8b-45b9-4653-ba55-5f855dd0fb88' //Storage Queue Data Contributor role

resource storageAccountAudiosRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccountAudios.id, storageQueueDataContributorRoleFuncStdDefinitionId)
  scope: storageAccountAudios
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageQueueDataContributorRoleFuncStdDefinitionId)
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource storageFuncDrbl 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageFuncDrblName
}

var storageAccountContributorRoleDefinitionId = '86e8f5dc-a6e9-4c67-9d15-de283e8eac25' //Storage Account Contributor role

resource storageAccountContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageFuncDrbl.id, storageAccountContributorRoleDefinitionId)
  scope: storageFuncDrbl
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageAccountContributorRoleDefinitionId)
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

var storageQueueDataContributorRoleFuncDrblDefinitionId = '974c5e8b-45b9-4653-ba55-5f855dd0fb88' //Storage Queue Data Contributor role

resource storageAccountRoleQueueDataContributorFuncStdAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageFuncDrbl.id, storageQueueDataContributorRoleFuncDrblDefinitionId)
  scope: storageFuncDrbl
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageQueueDataContributorRoleFuncDrblDefinitionId)
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

var storageTableDataContributorRoleFuncDrblDefinitionId = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' //Storage Table Data Contributor role

resource storageAccountRoleTableDataContributorFuncDrblAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageFuncDrbl.id, storageTableDataContributorRoleFuncDrblDefinitionId)
  scope: storageFuncDrbl
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageTableDataContributorRoleFuncDrblDefinitionId)
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
}

var keyVaultSecretsUserRoleFuncDrblDefinitionId = '4633458b-17de-408a-b874-0445c86b69e6' //Key Vault Secrets User role

resource keyVaultSecretsUserFuncDrblAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(keyVault.id, keyVaultSecretsUserRoleFuncDrblDefinitionId)
  scope: keyVault
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleFuncDrblDefinitionId)
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource appInsightFuncStd 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightFuncStdName
}

var monitoringMetricsPublisherRoleFuncStdDefinitionId = '3913510d-42f4-4e42-8a64-420c390055eb' //Monitoring Metrics Publisher role

resource monitoringMetricsPublisherFuncStdAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appInsightFuncStd.id, monitoringMetricsPublisherRoleFuncStdDefinitionId)
  scope: appInsightFuncStd
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', monitoringMetricsPublisherRoleFuncStdDefinitionId)
    principalId: funcStdPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource appInsightFuncDrbl 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightFuncDrblName
}

var monitoringMetricsPublisherRoleFuncDrblDefinitionId = '3913510d-42f4-4e42-8a64-420c390055eb' //Monitoring Metrics Publisher role

resource monitoringMetricsPublisherFuncDrblAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appInsightFuncDrbl.id, monitoringMetricsPublisherRoleFuncDrblDefinitionId)
  scope: appInsightFuncDrbl
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', monitoringMetricsPublisherRoleFuncDrblDefinitionId)
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource azureOpenAI 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' existing = {
  name: azureOpenAIName
}

var cognitiveServicesOpenAIUserRoleFuncDrblDefinitionId = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' //Cognitive Services OpenAI User role

resource cognitiveServicesOpenAIUserFuncDrblAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(azureOpenAI.id, cognitiveServicesOpenAIUserRoleFuncDrblDefinitionId)
  scope: azureOpenAI
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesOpenAIUserRoleFuncDrblDefinitionId)
    principalId: funcDrblPrincipalId
    principalType: 'ServicePrincipal'
  }
}
