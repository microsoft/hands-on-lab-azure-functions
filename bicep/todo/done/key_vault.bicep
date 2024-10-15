resource vaults_kv_lab_sw_hol_bf80_01_name_resource 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: vaults_kv_lab_sw_hol_bf80_01_name
  location: 'swedencentral'
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: '313fe192d'
    accessPolicies: [
      {
        tenantId: '313fe192d'
        objectId: 'f6b4d113-32-4140ae804489'
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
        tenantId: '313fe192d'
        objectId: '67fa578712-abe029658531'
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
    enabledForDeployment: false
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enableRbacAuthorization: false
    vaultUri: 'https://${vaults_kv_lab_sw_hol_bf80_01_name}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource vaults_kv_lab_sw_hol_bf80_01_name_speechToTextApiKey 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: vaults_kv_lab_sw_hol_bf80_01_name_resource
  name: 'speechToTextApiKey'
  location: 'swedencentral'
  properties: {
    attributes: {
      enabled: true
    }
  }
}
