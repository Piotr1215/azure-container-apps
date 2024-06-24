#!/usr/bin/env bash

set -eou pipefail

# Enable Container Apps (Preview)
echo "Enable Container Apps (Preview)"
echo "Installing or updating az containerapp extension"

az extension add --name containerapp --upgrade

az provider register --namespace Microsoft.App

# Static variables
LOG_ANALYTICS_WORKSPACE="my-container-apps-logs"

echo "Provide below variables or accept the defaults"

# Provide initial variables and defaults
read -e -p "Enter resource group name: " -i "rg-app-container-test" group
read -e -p "Enter Container app environment name: " -i "dev" environment
read -e -p "Enter location for the resources (or canadacentral): " -i "northeurope" location

# Check if variables are provided and exit if not
if [ -z "$group" ] || [ -z "$environment" ] || [ -z "$location" ]; then
	echo "Provide resource group, container environment as well as preferred location"
	exit 0
fi

# Check if resource group already exists
groupExists=$(az group exists -n "$group")

if $groupExists; then
	echo "Resource group $group already exists"
	exit 0
else
	az group create --name "$group" --location "$location" --output json
	echo "Resource group $group successfully created in $location"
fi

# Create log analytics workspace
echo "Creating Log Analytics workspace $LOG_ANALYTICS_WORKSPACE in resource group $group"
az monitor log-analytics workspace create \
	--resource-group "$group" \
	--workspace-name "$LOG_ANALYTICS_WORKSPACE"

# Sleep 5 seconds to make sure workspace is created
sleep 5

# Workspace analytics id and secret
LOG_ANALYTICS_WORKSPACE_CLIENT_ID=$(az monitor log-analytics workspace show --query customerId -g "$group" -n "$LOG_ANALYTICS_WORKSPACE" --out tsv)
LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=$(az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g "$group" -n "$LOG_ANALYTICS_WORKSPACE" --out tsv)

# Create container app environment
echo "Creating container app environment $environment in resource group $group"
az containerapp env create \
	--name "$environment" \
	--resource-group "$group" \
	--logs-workspace-id "$LOG_ANALYTICS_WORKSPACE_CLIENT_ID" \
	--logs-workspace-key "$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET" \
	--location "$location"

# Create container app
echo "Creating container app in resource group $group"
az containerapp create \
	--name my-container-app \
	--resource-group "$group" \
	--environment "$environment" \
	--image piotrzan/nginx-demo:blue \
	--target-port 80 \
	--ingress 'external'

# Obtain FQDN of the running container app with a specified API version
fqdn=$(az containerapp show --name my-container-app --resource-group "$group" --query properties.configuration.ingress.fqdn -o tsv)

echo ""
echo "To see the page live, navigate to: https://$fqdn"

# Cleanup
echo "To remove resource group with VM run: az group delete --name $group"
