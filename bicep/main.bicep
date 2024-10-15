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

@description('Name of the application')
param resourceGroupNameSuffix string = '01'

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

var resourceSuffix = [
  toLower(environment)
  substring(toLower(location), 0, 2)
  substring(toLower(application), 0, 3)
  substring(toLower(uniqueString(subscription().id, environment, application)), 0, 6)
  resourceGroupNameSuffix
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

module loadTesting './modules/testing/load_testing.bicep' = {
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

module storageAccountAudios './modules/storage/storage_account.bicep' = {
  name: 'storageAccountAudios'
  scope: resourceGroup
  params: {
    name: 'sto-${resourceSuffixKebabcase}'
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
