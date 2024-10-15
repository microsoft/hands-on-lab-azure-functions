resource accounts_oai_lab_sw_hol_bf80_01_name_resource 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' = {
  name: accounts_oai_lab_sw_hol_bf80_01_name
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
  kind: 'OpenAI'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiProperties: {}
    customSubDomainName: accounts_oai_lab_sw_hol_bf80_01_name
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: false
    allowedFqdnList: []
    disableLocalAuth: false
    dynamicThrottlingEnabled: false
  }
}

resource accounts_oai_lab_sw_hol_bf80_01_name_gpt_4o_mini 'Microsoft.CognitiveServices/accounts/deployments@2024-06-01-preview' = {
  parent: accounts_oai_lab_sw_hol_bf80_01_name_resource
  name: 'gpt-4o-mini'
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
