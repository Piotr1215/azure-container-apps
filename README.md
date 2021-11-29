# Azure Container Apps

Subtitle: Microservices on containers

Container Apps is a new serverless offering from Azure. As of the time when this article is published, it is still in preview.

The reason this offering is interesting is that it fills the gap between serverless and full blown Kubernetes setup. Traditionally for microservice type workloads one would use either serverless or Kubernetes.

This was not ideal as serverless is more suitable for event driven architectures, whereas Kubernetes is complex and requires specialized knowledge to run production grade workloads.

**Microservices architecture moves complexity from inside of a program to surrounding infrastructure.**

Another solution was to use [Azure Container Instances](https://azure.microsoft.com/en-us/services/container-instances/). This is a great service, but for one it's relatively low level and doesn't work well where multiple container groups are used especially when they need to communicate with each other.

> You can read more about Azure Container Instances my other blogs, [Easily Deploy Containers to Azure directly from your Desktop](https://itnext.io/easily-deploy-containers-to-azure-directly-from-your-desktop-16efebc87b21) and [Azure explained deep enough: Containers](Azure explained deep enough: Containers).

In this article we will explore how Azure Container Apps helps with microservices based architecture. This should be an interesting read if you are a developer or software architect designing software on Azure.

### What are the benefits

Container Apps is the missing link between serverless and AKS for microservices based architecture.

This is achieved by utilizing open source projects to provide standardized capabilities typically seen in microservices such as:

- auto-scaling
- secret and configuration management
- versioning
- advanced deployment capabilities, for example blue green deployment or A/B testing
- traffic splitting between revisions
- background, long running services

Here are the open source projects that power Container Apps:

Under the hood, container apps runs on AKS cluster with opinionated settings. This offering follows one of the best practices when leveraging Kubernetes:

> Kubernetes is a platform to build platforms

[DAPR](https://dapr.io/) provides platform and language agnostic building blocks for microservice based architectures. [KEDA](https://keda.sh/) provides seamless event driven auto-scaling capabilities. Finally [Envoy](https://www.envoyproxy.io/) takes tare of ingress and routing hiding Kubernetes complexity.

## When to use Container Apps

This service is best suited for microservices ideally if they are already containerised. A system that is not so complex that it requires direct access to Kubernetes primitives, but also business logic that is not purely event driven.

Personally, this is a service I've been waiting for. For me, it is powerful enough for moderately complex microservices setups and provides enough knobs and switches to configure even highly demanding workflows.

## Demo Scenarios

If you want to practice along, I've created [a repo with devcontainer setup](https://github.com/Piotr1215/azure-container-apps) covering 2 separate scenarios.
The first scenario located in folder `1.Hello-World` will deploy a sample "hello world" web app and expose entpoint as internal ingress.
Second scenario uses [bicep](https://docs.microsoft.com/EN-US/azure/azure-resource-manager/bicep/) to deploy additional configuration and showcase usage of secrets in contianer app.

### Prerequisites

There are a few prerequisites:

- VS Code
- Azure subscription
- Docker host running on your machine

1. Clone the repository: https://github.com/Piotr1215/azure-container-apps
2. VS Code should prompt you to reopen the repo in devcontainer

![container-reopen-prompt](media/container-reopen-prompt.png)

If the prompt does not appear, you can use <kbd>F1</kbd> or <kbd>Ctrl+Shift+P</kbd> and select _Reopen in Container_.

You need to perform [az login](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli). By default, az login command will open up a browser to securely authenticate with Azure subscription.

### Hello World

To start with the example, navigate to the `1.Hello-World` directory and run `setup.sh`.

You will be prompted to provide a few variables for the script. Default values are pre-populated. If you want to use the default values, just hit <kbd>enter</kbd>.

> At this point the Container Apps service is available only in the _northeurope_ and _canadacentral_ regions.

![hello-world-initial-setup](media/hello-world-initial-setup.png)

The script will perform following actions:

- install container apps az extension
- create a resource group
- create a container app environment
- create a container app
- deploy a hello world contianer to the container app
- expose url where you can check the web app live
- provide instructions to clean up resources

Once the script finishes, a URL with the running web app will be displayed as well as a command to delete the environment afterwards.

![hello-world-finish](media/hello-world-finish.png)

The URL should show a running hello world app:

![hello-world-running](media/hello-world-running.png)

Container Apps integrate fully with Azure Monitor observability. Navigate to Azure Portal and find the resource group

> If you have accepted the default values it will be _rg-app-container-test_

From there we can execute a simple query to read the stdin logs from sample app:

![hello-world-logs](media/hello-world-logs.png)

```sql
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == 'my-container-app'
| project ContainerAppName_s, ContainerImage_s, format_datetime(TimeGenerated, "hh:mm:ss"), RevisionName_s, EnvironmentName_s, Log_s
```

### State Store with Bicep

To start with the example, navigate to the `2.Bicep-Deploy` directory and run `setup.sh`.

> Bicep is out of scope for this article, but if you are interested, it's worth poining out that together with az CLI, it creates a nice combination of _imperative_ and _declarative_ style of IaC
