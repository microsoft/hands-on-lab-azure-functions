param name string
param location string = resourceGroup().location
param tags object = {}

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Consumption'
    capacity: 0
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: 'company@hol.io'
    publisherName: 'Hands On Lab Company'
  }
}

output id string = apim.id
output name string = apim.name
