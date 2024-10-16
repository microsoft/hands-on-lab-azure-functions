param name string
param location string = resourceGroup().location
param tags object = {}

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

output id string = speechToTextService.id
output name string = speechToTextService.name
output endpoint string = speechToTextService.properties.endpoint
