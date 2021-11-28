#!/usr/bin/env bash

set -euo pipefail

az bicep install

az group create -n rg-test-cap -l northeurope

az deployment group create --name blazor-in-container \
    --resource-group rg-test-cap \
    --template-file ./main.bicep \
    --parameters containerImage=piotrzan/blazorindocker:latest \
                 containerPort=80
