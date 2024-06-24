#!/usr/bin/env bash

set -eou pipefail

# Provide initial variables and defaults
read -e -p "Enter resource group name: " -i "rg-app-container-test" group
read -e -p "Enter Container app environment name: " -i "dev" environment

# Check if variables are provided and exit if not
if [ -z "$group" ] || [ -z "$environment" ]; then
	echo "Provide resource group and container environment"
	exit 0
fi

# Deploy blue version of the container app
echo "Deploying blue version of the container app"
az containerapp update \
	--name my-container-app \
	--resource-group "$group" \
	--image piotrzan/nginx-demo:blue

# Deploy green version of the container app
echo "Deploying green version of the container app"
az containerapp update \
	--name my-container-app \
	--resource-group "$group" \
	--image piotrzan/nginx-demo:green

# Enable multiple revisions
echo "Enabling multiple revisions"
az containerapp revision set-mode \
	--name my-container-app \
	--resource-group "$group" \
	--mode multiple

# List revisions and capture their names
echo "Listing revisions"
revisions=($(az containerapp revision list \
	--name my-container-app \
	--resource-group "$group" \
	--query '[].{Name:name}' \
	--output tsv))

# Check if there are exactly two revisions
if [ ${#revisions[@]} -ne 2 ]; then
	echo "Error: Expected exactly two revisions, but found ${#revisions[@]}"
	exit 1
fi

blue_revision=${revisions[0]}
green_revision=${revisions[1]}

# Prompt user to enter weights
read -e -p "Enter the weight for blue revision (e.g., 75): " -i "75" blue_weight
read -e -p "Enter the weight for green revision (e.g., 25): " -i "25" green_weight

# Split traffic
echo "Splitting traffic between revisions"
az containerapp ingress traffic set \
	--name my-container-app \
	--resource-group "$group" \
	--revision-weight $blue_revision=$blue_weight $green_revision=$green_weight

echo "A/B testing setup complete. Traffic is split between $blue_revision ($blue_weight%) and $green_revision ($green_weight%)."
