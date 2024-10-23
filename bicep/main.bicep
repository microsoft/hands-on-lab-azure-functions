targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name which is used to generate a short unique hash for each resource')
param name string

@description('The environment deployed')
@allowed(['lab', 'dev', 'stg', 'prd'])
param environment string = 'lab'

@description('Name of the application')
param application string = 'hol'

@description('The location where the resources will be created.')
@allowed([
  'eastus'
  'eastus2'
  'southcentralus'
  'swedencentral'
  'westus3'
])
param location string = 'swedencentral'

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {
  'azd-env-name': name
  Deployment: 'bicep'
  Environment: environment
  Location: location
  Application: application
}

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('Whether the deployment is running on GitHub Actions')
param runningOnGh string = ''

@description('Whether the deployment is running on Azure DevOps Pipeline')
param runningOnAdo string = ''

var principalType = empty(runningOnGh) && empty(runningOnAdo) ? 'User' : 'ServicePrincipal'

var resourceToken = toLower(uniqueString(subscription().id, name, environment, application))
var resourceSuffix = [
  toLower(environment)
  substring(toLower(location), 0, 2)
  substring(toLower(application), 0, 3)
  substring(resourceToken, 0, 8)
]
var resourceSuffixKebabcase = join(resourceSuffix, '-')
var resourceSuffixLowercase = join(resourceSuffix, '')

@description('The resource group.')
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourceSuffixKebabcase}'
  location: location
  tags: tags
}

module logAnalytics './modules/monitor/log.bicep' = {
  name: 'logAnalytics'
  scope: resourceGroup
  params: {
    name: 'log-${resourceSuffixKebabcase}'
    tags: tags
  }
}

module loadTesting './modules/testing/load-testing.bicep' = {
  name: 'loadTesting'
  scope: resourceGroup
  params: {
    name: 'lt-${resourceSuffixKebabcase}'
    tags: tags
  }
}

module azureOpenAI './modules/ai/openai.bicep' = {
  name: 'azureOpenAI'
  scope: resourceGroup
  params: {
    name: 'oai-${resourceSuffixKebabcase}'
    tags: tags
  }
}

module apim './modules/apis/apim.bicep' = {
  name: 'apim'
  scope: resourceGroup
  params: {
    name: 'apim-${resourceSuffixKebabcase}'
    tags: tags
  }
}

module storageAccountAudios './modules/storage/storage-account.bicep' = {
  name: 'storageAccountAudios'
  scope: resourceGroup
  params: {
    name: take('sto${resourceSuffixLowercase}', 24)
    tags: tags
    containers: [{name: 'audios'}]
  }
}

module eventGrid './modules/events/event_grid.bicep' = {
  name: 'eventGrid'
  scope: resourceGroup
  params: {
    name: 'evgt-audio-${resourceSuffixKebabcase}'
    tags: tags
    storageAccountId: storageAccountAudios.outputs.storageId
  }
}

module cosmosDb './modules/storage/cosmos-db.bicep' = {
  name: 'cosmosDb'
  scope: resourceGroup
  params: {
    name: 'cosmos-${resourceSuffixKebabcase}'
    tags: tags
  }
}

// Standard Azure Functions Flex Consumption

var uploaderDeploymentPackageContainerName = 'uploaderdeploymentpackage'
var processorDeploymentPackageContainerName = 'processordeploymentpackage'

module storageAccountFunctions './modules/storage/storage-account.bicep' = {
  name: 'storageAccountFunctions'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    name: take('stfunc${resourceSuffixLowercase}', 24)
    containers: [
      {name: uploaderDeploymentPackageContainerName}
      {name: processorDeploymentPackageContainerName}
    ]
  }
}

module applicationInsights './modules/monitor/application-insights.bicep' = {
  name: 'applicationInsights'
  scope: resourceGroup
  params: {
    name: 'appi-${resourceSuffixKebabcase}'
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

module uploaderFunction './modules/host/function.bicep' = {
  name: 'uploaderFunction'
  scope: resourceGroup
  params: {
    planName: 'asp-std-${resourceSuffixKebabcase}'
    appName: 'func-std-${resourceSuffixKebabcase}'
    applicationInsightsName: applicationInsights.outputs.name
    storageAccountName: storageAccountFunctions.outputs.name
    deploymentStorageContainerName: uploaderDeploymentPackageContainerName
    azdServiceName: 'uploader'
    tags: tags
    appSettings: [
      {
        name  : 'AudioUploadStorage__serviceUri'
        value : 'https://${storageAccountAudios.outputs.name}.blob.core.windows.net'
      }
      {
        name  : 'STORAGE_ACCOUNT_CONTAINER'
        value : storageAccountAudios.outputs.containers[0].name
      }
      {
        name  : 'COSMOS_DB_DATABASE_NAME'
        value : cosmosDb.outputs.databaseName
      }
      {
        name  : 'COSMOS_DB_CONTAINER_ID'
        value : cosmosDb.outputs.containerName
      }
      {
        name  : 'COSMOS_DB__accountEndpoint'
        value :  cosmosDb.outputs.endpoint
      }
      {
        name  : 'ERROR_RATE'
        value : '0'
      }
      {
        name  : 'LATENCY_IN_SECONDS'
        value : '0'
      }
    ]
  }
}

// Durable Azure Functions Flex Consumption
module processorFunction './modules/host/function.bicep' = {
  name: 'processorFunction'
  scope: resourceGroup
  params: {
    planName: 'asp-drbl-${resourceSuffixKebabcase}'
    appName: 'func-drbl-${resourceSuffixKebabcase}'
    applicationInsightsName: applicationInsights.outputs.name
    storageAccountName: storageAccountFunctions.outputs.name
    deploymentStorageContainerName: processorDeploymentPackageContainerName
    azdServiceName: 'processor'
    tags: tags
    appSettings: [
      {
        name  : 'STORAGE_ACCOUNT_URL'
        value : 'https://${storageAccountAudios.outputs.name}.blob.core.windows.net'
      }
      {
        name  : 'STORAGE_ACCOUNT_CONTAINER'
        value : storageAccountAudios.outputs.containers[0].name
      }
      {
        name  : 'STORAGE_ACCOUNT_EVENT_GRID__blobServiceUri'
        value : 'https://${storageAccountAudios.outputs.name}.blob.core.windows.net'
      }
      {
        name  : 'STORAGE_ACCOUNT_EVENT_GRID__queueServiceUri'
        value : 'https://${storageAccountAudios.outputs.name}.queue.core.windows.net'
      }
      {
        name  : 'SPEECH_TO_TEXT_ENDPOINT'
        value : speechToTextService.outputs.endpoint
      }
      {
        name  : 'SPEECH_TO_TEXT_API_KEY'
        value : '@Microsoft.KeyVault(SecretUri=${speechToTextService.outputs.secretUri})'
      }
      {
        name  : 'COSMOS_DB_DATABASE_NAME'
        value : cosmosDb.outputs.databaseName
      }
      {
        name  : 'COSMOS_DB_CONTAINER_ID'
        value : cosmosDb.outputs.containerName
      }
      {
        name  : 'COSMOS_DB__accountEndpoint'
        value :  cosmosDb.outputs.endpoint
      }
      {
        name  : 'AZURE_OPENAI_ENDPOINT'
        value : azureOpenAI.outputs.endpoint
      }
      {
        name  : 'CHAT_MODEL_DEPLOYMENT_NAME'
        value : azureOpenAI.outputs.gpt4oMinideploymentName
      }
    ]
  }
}

module keyVault './modules/security/key-vault.bicep' = {
  name: 'keyVault'
  scope: resourceGroup
  params: {
    name: take('kv-${resourceSuffixKebabcase}', 24)
    tags: tags
  }
}

module speechToTextService './modules/ai/speech-to-text-service.bicep' = {
  name: 'speechToTextService'
  scope: resourceGroup
  params: {
    name: 'spch-${resourceSuffixKebabcase}'
    tags: tags
    keyVaultName: keyVault.outputs.name
  }
}

module roles './modules/security/roles.bicep' = {
  name: 'roles'
  scope: resourceGroup
  params: {
    cosmosDbAccountName: cosmosDb.outputs.name
    funcStdPrincipalId: uploaderFunction.outputs.principalId
    funcDrblPrincipalId: processorFunction.outputs.principalId
    userPrincipalId: principalId
    userPrincipalType: principalType
    appInsightsName: applicationInsights.outputs.name
    keyVaultName: keyVault.outputs.name
    storageAccountAudiosName: storageAccountAudios.outputs.name
    storageFuncDrblName: storageAccountFunctions.outputs.name
    azureOpenAIName: azureOpenAI.outputs.name
  }
  dependsOn: [cosmosDb]
}

output RESOURCE_GROUP string = resourceGroup.name
output AZURE_UPLOADER_FUNCTION_APP_NAME string = uploaderFunction.outputs.name
output AZURE_PROCESSOR_FUNCTION_APP_NAME string = processorFunction.outputs.name
output AUDIOS_STORAGE_ACCOUNT_CONTAINER_NAME string = storageAccountAudios.outputs.containers[0].name
output AUDIOS_EVENTGRID_SYSTEM_TOPIC_NAME string = eventGrid.outputs.name
