resource systemTopics_evgt_audio_lab_sw_hol_bf80_01_name_resource 'Microsoft.EventGrid/systemTopics@2024-06-01-preview' = {
  name: systemTopics_evgt_audio_lab_sw_hol_bf80_01_name
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
    source: storageAccounts_stlabswholbf8001_name_resource.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}
