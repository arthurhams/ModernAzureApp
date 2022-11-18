param location string = resourceGroup().location

param virtualNetworkName string

param subnetName string
param subnetAddressPrefix string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix // '10.0.0.0/24'
        }
      }
    ]
  }

  resource subnet 'subnets' existing = {
    name: subnetName
  }
}

output subnetResourceId string = virtualNetwork::subnet.id
