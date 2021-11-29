#!/usr/bin/env bash

set -euo pipefail

# Enable Contianer Apps (Preview)
echo "Enable Contianer Apps (Preview)"
echo "Installing az containerapp extension"

mapfile -t result < <(az extension list | grep containerapp)
num=${#result[@]}

if ((num == 0)); then
  az extension add \
    --source https://workerappscliextension.blob.core.windows.net/azure-cli-extension/containerapp-0.2.0-py2.py3-none-any.whl --yes
fi

az provider register --namespace Microsoft.Web

az deployment create \
    --name blazor-in-container \
    --location northeurope \
    --template-file ./main.bicep \
    --parameters containerImage=piotrzan/go-sample-azure-storage:v1 \
                 containerPort=8080

# Obrain FQDN of the running container app
fqdn=$(az containerapp show --name sample-app --resource-group rg-test-containerapps --query configuration.ingress.fqdn -o tsv)

echo ""
echo "To interact with the storage account, navigate to:" "https://$fqdn"