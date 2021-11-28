#!/usr/bin/env bash

set -euo pipefail

az deployment create \
    --name blazor-in-container \
    --location northeurope \
    --template-file ./main.bicep \
    --parameters containerImage=piotrzan/blazorindocker:latest \
                 containerPort=80
