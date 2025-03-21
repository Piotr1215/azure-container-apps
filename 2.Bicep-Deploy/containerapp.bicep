// general Azure Container App settings
param location string
param name string
param containerAppEnvironmentId string

// Container Image ref
param containerImage string

// Networking
param useExternalIngress bool = false
param containerPort int

// Storage Account Connection String
@secure()
param storageKey string

param envVars array = []

resource containerApp 'Microsoft.Web/containerApps@2024-04-01' = {
  name: name
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: containerAppEnvironmentId
    configuration: {
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
      }
      secrets: [
        {
          name: 'storage-account-connection'
          value: storageKey
        }
      ]
    }
    template: {
      containers: [
        {
          image: containerImage
          name: name
          env: envVars
        }
      ]
      scale: {
        minReplicas: 0
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
