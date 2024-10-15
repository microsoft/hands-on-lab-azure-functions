param name string
param location string = resourceGroup().location
param tags object = {}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: name
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  identity: {
    type: 'None'
  }
  properties: {
    // publicNetworkAccess: 'Enabled'
    // enableAutomaticFailover: false
    // enableMultipleWriteLocations: false
    // isVirtualNetworkFilterEnabled: false
    // virtualNetworkRules: []
    // disableKeyBasedMetadataWriteAccess: false
    // enableFreeTier: false
    // enableAnalyticalStorage: false
    // analyticalStorageConfiguration: {
    //   schemaType: 'WellDefined'
    // }
    databaseAccountOfferType: 'Standard'
    // defaultIdentity: 'FirstPartyIdentity'
    // networkAclBypass: 'None'
    // disableLocalAuth: false
    // enablePartitionMerge: false
    // enableBurstCapacity: false
    // minimalTlsVersion: 'Tls12'
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
    // cors: []
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    // ipRules: []
    // backupPolicy: {
    //   type: 'Periodic'
    //   periodicModeProperties: {
    //     backupIntervalInMinutes: 240
    //     backupRetentionIntervalInHours: 8
    //     backupStorageRedundancy: 'Geo'
    //   }
    // }
    // networkAclBypassResourceIds: []
  }
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: cosmosDb
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
          // {
          //   path: '/"_etag"/?'
          // }
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
      // conflictResolutionPolicy: {
      //   mode: 'LastWriterWins'
      //   conflictResolutionPath: '/_ts'
      // }
      // computedProperties: []
    }
  }
}

output id string = cosmosDb.id
output name string = cosmosDb.name
