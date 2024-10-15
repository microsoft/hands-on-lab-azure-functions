
resource accounts_cog_lab_sw_hol_bf80_01_name_resource 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' = {
  name: accounts_cog_lab_sw_hol_bf80_01_name
  location: 'swedencentral'
  tags: {
    Application: 'hol'
    Deployment: 'terraform'
    Environment: 'lab'
    Location: 'swedencentral'
    ProjectName: 'hands-on-lab-azure-functions'
    'Resource Suffix': '01'
  }
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
    allowedFqdnList: []
    disableLocalAuth: false
    dynamicThrottlingEnabled: false
  }
}
