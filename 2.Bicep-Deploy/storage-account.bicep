param name string

resource simpleStorage 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: name
  kind: 'StorageV2'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: true
  }

}

resource mainstoragecontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${simpleStorage.name}/default/${blobContainerName}'
  properties: {
    publicAccess: 'Container'
  }
  dependsOn: [
    simpleStorage
  ]
}

var key1 = simpleStorage.listKeys().keys[0].value

var blobContainerName = 'test-container'

output storageKey string = key1
output storageApiVersion string = simpleStorage.apiVersion
output storageAccountName string = simpleStorage.name
