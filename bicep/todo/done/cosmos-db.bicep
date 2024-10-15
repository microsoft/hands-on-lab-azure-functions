resource databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_resource 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: databaseAccounts_cosmos_lab_sw_hol_bf80_01_name
  location: 'Sweden Central'
  tags: {
    Application: 'hol'
    Deployment: 'terraform'
    Environment: 'lab'
    Location: 'swedencentral'
    ProjectName: 'hands-on-lab-azure-functions'
    'Resource Suffix': '01'
  }
  kind: 'GlobalDocumentDB'
  identity: {
    type: 'None'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    disableKeyBasedMetadataWriteAccess: false
    enableFreeTier: false
    enableAnalyticalStorage: false
    analyticalStorageConfiguration: {
      schemaType: 'WellDefined'
    }
    databaseAccountOfferType: 'Standard'
    defaultIdentity: 'FirstPartyIdentity'
    networkAclBypass: 'None'
    disableLocalAuth: false
    enablePartitionMerge: false
    enableBurstCapacity: false
    minimalTlsVersion: 'Tls12'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: 'Sweden Central'
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    cors: []
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    ipRules: []
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Geo'
      }
    }
    networkAclBypassResourceIds: []
  }
}

resource databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_HolDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_resource
  name: 'HolDb'
  properties: {
    resource: {
      id: 'HolDb'
    }
  }
}



resource databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_HolDb_audios_transcripts 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_HolDb
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
          {
            path: '/"_etag"/?'
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
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
      computedProperties: []
    }
  }
  dependsOn: [
    databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_resource
  ]
}
