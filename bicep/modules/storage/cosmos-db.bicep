param name string
param location string = resourceGroup().location
param tags object = {}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: name
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  identity: {
    type: 'None'
  }
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: cosmosDbAccount
  name: 'HolDb'
  properties: {
    resource: {
      id: 'HolDb'
    }
  }
}

resource cosmosDbAudiosTranscriptsContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: cosmosDbDatabase
  name: 'audios_transcripts'
  properties: {
    resource: {
      id: 'audios_transcripts'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
          {
            path: '/included/?'
          }
        ]
        excludedPaths: [
          {
            path: '/excluded/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
        version: 1
      }
      uniqueKeyPolicy: {
        uniqueKeys: [
          {
            paths: [
              '/idshort'
              '/idlong'
            ]
          }
        ]
      }
    }
  }
}

output id string = cosmosDbAccount.id
output name string = cosmosDbAccount.name
output endpoint string = cosmosDbAccount.properties.documentEndpoint
output databaseName string = cosmosDbDatabase.name
output containerName string = cosmosDbAudiosTranscriptsContainer.name
