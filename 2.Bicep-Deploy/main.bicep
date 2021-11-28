targetScope = 'subscription' :hand: 

param envName string = 'dev'

param containerImage string
param containerPort int

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-test-containerapps'
  location: deployment().location
}

module storage 'storage-account.bicep' = {
  name: 'V2StorageAccount'
  scope: rg
  params: {
    name: 'containerappstorage123'
  }
}

module law 'law.bicep' = {
    name: 'log-analytics-workspace'
    scope: rg
    params: {
      location: deployment().location
      name: 'law-${envName}'
    }
}

module containerAppEnvironment 'environment.bicep' = {
  name: 'container-app-environment'
  scope: rg
  params: {
    name: envName
    location: deployment().location
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module containerApp 'containerapp.bicep' = {
  name: 'sample'
  scope: rg
  params: {
    storageAccountConnectionString: blobStorageConnectionString
    name: 'sample-app'
    location: deployment().location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    containerPort: containerPort
    envVars: [
        {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Development'
        }
    ]
    useExternalIngress: true
  }
}

var blobStorageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storage.outputs.storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.outputs.storageKey}'

output fqdn string = containerApp.outputs.fqdn
output storageSonnectionString string = blobStorageConnectionString
