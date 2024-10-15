resource workspaces_log_lab_sw_hol_bf80_01_name_resource 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaces_log_lab_sw_hol_bf80_01_name
  location: 'swedencentral'
  tags: {
    Application: 'hol'
    Deployment: 'terraform'
    Environment: 'lab'
    Location: 'swedencentral'
    ProjectName: 'hands-on-lab-azure-functions'
    'Resource Suffix': '01'
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
      disableLocalAuth: false
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}



resource components_appi_std_lab_sw_hol_bf80_01_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_appi_std_lab_sw_hol_bf80_01_name
  location: 'swedencentral'
  tags: {
    Application: 'hol'
    Deployment: 'terraform'
    Environment: 'lab'
    Location: 'swedencentral'
    ProjectName: 'hands-on-lab-azure-functions'
    'Resource Suffix': '01'
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
    SamplingPercentage: 100
    RetentionInDays: 90
    DisableIpMasking: false
    WorkspaceResourceId: workspaces_log_lab_sw_hol_bf80_01_name_resource.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    DisableLocalAuth: true
    ForceCustomerStorageForProfiler: false
  }
}
