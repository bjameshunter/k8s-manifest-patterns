#!/bin/bash

FLUX_KEY=$(fluxctl identity --k8s-fwd-ns fluxcd)
FLUX_JSON="{\"key\": \"${FLUX_KEY}\"}"
echo $FLUX_JSON
