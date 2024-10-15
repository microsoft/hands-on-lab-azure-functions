param name string
param location string = resourceGroup().location
param tags object = {}

resource loadTesting 'Microsoft.LoadTestService/loadTests@2022-12-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
}

output id string = loadTesting.id
output name string = loadTesting.name
