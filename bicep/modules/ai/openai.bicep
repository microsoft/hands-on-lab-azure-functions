param name string
param tags object = {}

resource openAI 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' = {
  name: name
  location: 'swedencentral'
  tags: tags
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiProperties: {}
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: false
    allowedFqdnList: []
    disableLocalAuth: false
    dynamicThrottlingEnabled: false
  }
}

resource gpt4oMini 'Microsoft.CognitiveServices/accounts/deployments@2024-06-01-preview' = {
  parent: openAI
  name: 'gpt4oMini'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o-mini'
      version: '2024-07-18'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: 10
  }
}

output id string = openAI.id
output endpoint string = openAI.properties.endpoint
output gpt4oMinideploymentName string = gpt4oMini.properties.model.name

