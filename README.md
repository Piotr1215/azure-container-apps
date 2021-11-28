# Azure Container Apps

- [Table of Contents](#table-of-contents)
          - [Compare other offerings](#compare-other-offerings)
          - [Explain DAPR briefly](#explain-dapr-briefly)
          - [Diagram with component architecture](#diagram-with-component-architecture)
          - [Sequence diagram with revision flow](#sequence-diagram-with-revision-flow)
     - [Demo Scenarios](#demo-scenarios)
          - [Hello World](#hello-world)
          - [State Store with Bicep](#state-store-with-bicep)
          - [Introduction to DAPR](#introduction-to-dapr)

Container Apps is a new serverless offering from Azure. 

### Compare other offerings
### Explain DAPR briefly
### Diagram with component architecture
### Sequence diagram with revision flow

## Demo Scenarios

If you want to practice along, I've created [a repo with devcontainer setup](https://github.com/Piotr1215/azure-container-apps) covering 3 separate scenarios.

There are a few prerequisites:

- VS Code
- Azure subscription
- Docker host running on your machine 

### Hello World

- az login
- run ./setup.sh, this will
    - install container apps extension
    - create a resource group
    - create a container app environment
    - create a container app
    - deploy a hello world contianer to it
    - expose url where you can check the web app live
    - provide instructions to clean up resources

### State Store with Bicep

### Introduction to DAPR

