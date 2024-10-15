resource userAssignedIdentities_id_func_std_lab_sw_hol_bf80_01_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: userAssignedIdentities_id_func_std_lab_sw_hol_bf80_01_name
  location: 'swedencentral'
  tags: {
    Application: 'hol'
    Deployment: 'terraform'
    Environment: 'lab'
    Location: 'swedencentral'
    ProjectName: 'hands-on-lab-azure-functions'
    'Resource Suffix': '01'
  }
}
