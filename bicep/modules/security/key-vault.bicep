param name string
param location string = resourceGroup().location
param tags object = {}
param speechToTextApiKey string
param funcDrblId string

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: [
      {
        tenantId: tenant().tenantId
        objectId: 'TODO'
        permissions: {
          certificates: []
          keys: []
          secrets: [
            'Get'
            'List'
            'Set'
            'Delete'
            'Purge'
            'Recover'
          ]
          storage: []
        }
      }
      {
        tenantId: tenant().tenantId
        objectId: funcDrblId
        permissions: {
          certificates: []
          keys: []
          secrets: [
            'Get'
            'List'
          ]
          storage: []
        }
      }
    ]
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    publicNetworkAccess: 'Enabled'
  }
}

resource speechToTextApiKeySecret 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'speechToTextApiKeySecret'
  tags: tags
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: speechToTextApiKey
  }
}
