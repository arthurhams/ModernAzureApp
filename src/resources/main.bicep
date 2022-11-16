param AFDName string 

module AzureFrontDoor 'modules/AzureFrontDoor/frontdoor.bicep' = {
  name: 'AzureFrontDoor'
  params: {
    AzureFrontDoorResourceName : AFDName
  }
}
