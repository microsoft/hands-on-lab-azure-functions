targetScope = 'subscription'

@description('The environment deployed')
@allowed(['lab', 'dev', 'stg', 'prd'])
param environment string = 'lab'

@description('Name of the application')
param application string = 'hol'

@description('The location where the resources will be created.')
@allowed([
  'swedencentral'
  'eastus'
  'eastus2'
  'northeurope'
  'southcentralus'
  'southeastasia'
  'swedencentral'
  'uksouth'
  'westus2'
  'eastus2euap'
])
param location string = 'swedencentral'

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

var resourceToken = toLower(uniqueString(subscription().id, environment, application))
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

module openAI './modules/ai/openai.bicep' = {
  name: 'openAI'
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
    name: 'sto${resourceSuffixLowercase}'
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

var deploymentPackageContainerName = 'deploymentpackage'

module storageAccountFuncStd './modules/storage/storage-account.bicep' = {
  name: 'storageAccountFuncStd'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    name: 'stfstd${resourceSuffixLowercase}'
    containers: [{name: deploymentPackageContainerName}]
  }
}

module applicationInsightsFuncStd './modules/monitor/application-insights.bicep' = {
  name: 'applicationInsightsFuncStd'
  scope: resourceGroup
  params: {
    name: 'appi-std-${resourceSuffixKebabcase}'
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

module functionStdFlex './modules/host/function.bicep' = {
  name: 'functionStdFlex'
  scope: resourceGroup
  params: {
    tags: tags
    planName: 'asp-std-${resourceSuffixKebabcase}'
    appName: 'func-std-${resourceSuffixKebabcase}'
    applicationInsightsName: applicationInsightsFuncStd.outputs.name
    storageAccountName: storageAccountFuncStd.outputs.name
    deploymentStorageContainerName: deploymentPackageContainerName
  }
}

// Durable Azure Functions Flex Consumption

module storageAccountFuncDrbl './modules/storage/storage-account.bicep' = {
  name: 'storageAccountFuncDrbl'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    name: 'stfdrbl${resourceSuffixLowercase}'
    containers: [{name: deploymentPackageContainerName}]
  }
}

module applicationInsightsFuncDrbl './modules/monitor/application-insights.bicep' = {
  name: 'applicationInsightsFuncDrbl'
  scope: resourceGroup
  params: {
    name: 'appi-drbl-${resourceSuffixKebabcase}'
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

module functionDrblFlex './modules/host/function.bicep' = {
  name: 'functionDrblFlex'
  scope: resourceGroup
  params: {
    tags: tags
    planName: 'asp-drbl-${resourceSuffixKebabcase}'
    appName: 'func-drbl-${resourceSuffixKebabcase}'
    applicationInsightsName: applicationInsightsFuncDrbl.outputs.name
    storageAccountName: storageAccountFuncDrbl.outputs.name
    deploymentStorageContainerName: deploymentPackageContainerName
  }
}

var speechToTextService = 'spch-${resourceSuffixKebabcase}'

module speechService './modules/ai/speech-to-text-service.bicep' = {
  name: 'speechService'
  scope: resourceGroup
  params: {
    name: speechToTextService
    tags: tags
  }
}

resource speechServiceDeployed 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' existing = {
  name: speechToTextService
  scope: resourceGroup
}

module keyVault './modules/security/key-vault.bicep' = {
  name: 'keyVault'
  scope: resourceGroup
  params: {
    name: 'kv-${resourceSuffixKebabcase}'
    funcDrblId: functionDrblFlex.outputs.id
    speechToTextApiKey: speechServiceDeployed.listKeys().key1
    tags: tags
  }
  dependsOn: [speechService]
}
