param name string
param location string = resourceGroup().location
param tags object = {}
param keyVaultName string

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
}

resource speechToTextService 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'S0'
  }
  kind: 'SpeechServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: false
  }
}

resource apiKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  parent: keyVault
  name: 'speech-to-text-api-key'
  properties: {
    value: speechToTextService.listKeys().key1
  }
}

output id string = speechToTextService.id
output name string = speechToTextService.name
output endpoint string = speechToTextService.properties.endpoint
output secretUri string = apiKeySecret.properties.secretUriWithVersion
