

resource databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_00000000_0000_0000_0000_000000000001 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-05-15' = {
  parent: databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_resource
  name: '00000000-0000-0000-0000-000000000001'
  properties: {
    roleName: 'Cosmos DB Built-in Data Reader'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_00000000_0000_0000_0000_000000000002 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-05-15' = {
  parent: databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_resource
  name: '00000000-0000-0000-0000-000000000002'
  properties: {
    roleName: 'Cosmos DB Built-in Data Contributor'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_51f03358_a4a2_b520_f424_1f6b236c26ba 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  parent: databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_resource
  name: '51f03358-a4a2-b520-f424-1f6b236c26ba'
  properties: {
    roleDefinitionId: databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_00000000_0000_0000_0000_000000000002.id
    principalId: 'c47fe723-a348-4a3f-b954-91be9ed92138'
    scope: databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_resource.id
  }
}

resource databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_5e38f7ee_7651_6b27_ae5a_5eff3e14731b 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  parent: databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_resource
  name: '5e38f7ee-7651-6b27-ae5a-5eff3e14731b'
  properties: {
    roleDefinitionId: databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_00000000_0000_0000_0000_000000000002.id
    principalId: '67fa5756-20be-48d9-8712-abe029658531'
    scope: databaseAccounts_cosmos_lab_sw_hol_bf80_01_name_resource.id
  }
}
