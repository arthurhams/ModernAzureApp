targetScope = 'resourceGroup'

param location string = resourceGroup().location
param prefix string = 'modernapp'
param cnt int = 0
param logAnalyticsName string = '${prefix}${cnt}-laworkspace'
param appInsightName string = '${prefix}${cnt}-appinsights'
param acaEnvName string = '${prefix}${cnt}-aca-environment'
param storageAccountName string = '${prefix}${cnt}storageaccount'
param storageContainerName string = '${prefix}${cnt}containerr'
param storageQueueName string = '${prefix}${cnt}queue'
param storageSecKeyName string = 'StorageKey'
param storageSecAccountName string = 'StorageAccountName'
param storageSecContainerName string = 'ContainerName'

param deployServiceBus bool = false
param serviceBusNamespace string = '${prefix}${cnt}sb'
param serviceBusTopicName string = '${prefix}${cnt}-topic'
param serviceBusTopicSubName string = '${prefix}${cnt}-topic-frontend'

param deploySignalR bool = false
param signalRName string = '${prefix}${cnt}signalr'

param azureFrontDoorName string = '${prefix}${cnt}frontdoor'
param vNetName string = '${prefix}${cnt}-vnet'

param keyvaultName string = '${prefix}${cnt}-keyvault'
param uamiName string = '${prefix}${cnt}-app-identity'
param signalRKeyName string = 'SignalRConnectionString'

param containerRegistryName string = '${prefix}${cnt}containerregistry'

module vnet 'modules/vnet.bicep' = {
  name: vNetName
  params: {
    virtualNetworkName: vNetName
    vnetAddressPrefix: '10.0.0.0/16'
    subnetAddressPrefix: '10.0.0.0/24'
    subnetName: 'default' 
    location: location
  } 
}

module subnet1 'modules/subnet.bicep' = {
  name: vNetName
  params: {
    virtualNetworkName: vNetName
    subnetAddressPrefix: '10.0.0.1/24'
    subnetName: 'default' 
    location: location
  } 
}

module uami 'modules/identity.bicep' = {
  name: uamiName
  params: {
    uamiName: uamiName
    location: location
  }
}

module containerRegistry  'modules/registry.bicep' = {
  name: containerRegistryName
  params: {
    location: location
    registryName: containerRegistryName
    skuName: 'Basic'
    userAssignedIdentityPrincipalId: uami.outputs.principalId
    adminUserEnabled: false
  }
}

module keyvault 'modules/keyvault.bicep' = {
  name: keyvaultName
  params: {
    keyVaultName: keyvaultName
    objectId: uami.outputs.principalId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    keysPermissions: [
      'get'
      'list'
    ]
    secretsPermissions: [
      'get'
      'list'
    ]
    location: location
    skuName: 'standard'  
  }
}

module serviceBus 'modules/service-bus.bicep' = if(deployServiceBus) {
  name: 'xenielservicebus'  
  params: {
    serviceBusNamespace: serviceBusNamespace
    serviceBusTopicName: serviceBusTopicName
    serviceBusTopicSubName: serviceBusTopicSubName
    location: location
    identityPrincipalId: uami.outputs.principalId
  }
}

var eventGridTopicName = '${storageAccountName}-${serviceBusTopicName}-topic'
module eventgridTopicToServiceBus 'modules/eventGridServiceBus.bicep' = if(deployServiceBus) {
  name: eventGridTopicName
  dependsOn: [
    serviceBus
    storageAccount
  ]
  params: {
    eventGridSystemTopicName: eventGridTopicName 
    location: location
    serviceBusNamespace: serviceBus.outputs.namespace
    serviceBusTopicName: serviceBus.outputs.topicName
    storageAccountName: storageAccount.outputs.accountName
  }
}

module storageAccount 'modules/storageAccount.bicep' = {
  name: storageAccountName
  params: {
    accountName: storageAccountName
    containerName: storageContainerName
    queueName: storageQueueName
    location: location
    identityPrincipalId: uami.outputs.principalId
    keyVaultName: keyvault.name
    storageSecKeyName: storageSecKeyName
    storageSecAccountName: storageSecAccountName
    storageSecContainerName: storageSecContainerName
  }
}

module signalR 'modules/signalr.bicep' = if(deploySignalR) {
  name: signalRName
  params: {
    signalRName: signalRName
    location: location
    keyVaultName: keyvault.name
    signalRKeyName: signalRKeyName
  }
}

module logAnalytics 'modules/log-analytics.bicep' = {
  name: logAnalyticsName
  params: {
    logAnalyticsName: logAnalyticsName
    localtion: location
  }
}

module appInsights 'modules/appInsights.bicep' = {
  name: appInsightName
  params: {
    appInsightName: appInsightName
    location: location
    laWorkspaceId: logAnalytics.outputs.laWorkspaceId
  }
}

module acaEnvironment 'modules/environment.bicep' = {
  name: acaEnvName
  params: {
    appInsightKey: appInsights.outputs.InstrumentationKey
    location: location
    envrionmentName: acaEnvName
    laWorkspaceName: logAnalyticsName
  }
}

//provision a premium afd service
module azureFrontDoor 'modules/azurefrontdoor/azurefrontdoor.bicep' = {
  name: 'azureFrontDoor'
  params: {
    AzureFrontDoorResourceName : azureFrontDoorName
  }
}
