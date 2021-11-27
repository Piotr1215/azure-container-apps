#!/usr/bin/env bash

set -euo pipefail

az deployment group create -n container-app \
  -g rg-blog-sample \
  --template-file ./main.bicep \
  -p containerImage=blogsample.azurecr.io/api:0.0.1 \
     containerPort=5000 \

az deployment group create --name blazor-in-container \
    --resource-group rg-test-cap \
    --template-file ./main.bicep \
    --what-if \
    --parameters \
        --containerImage=piotrzan/blazorindocker:latest \
        --containerPort=80
