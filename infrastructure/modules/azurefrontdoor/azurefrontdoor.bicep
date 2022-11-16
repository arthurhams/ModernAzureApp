param AzureFrontDoorResourceName string

resource AFDResource 'Microsoft.Cdn/profiles@2022-05-01-preview' = {
  name: AzureFrontDoorResourceName
  location: 'Global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
     originResponseTimeoutSeconds: 60
     extendedProperties: {}
  }
}
