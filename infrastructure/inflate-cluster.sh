#!/bin/bash

# note:
# as of 2022-04-14 AKS is telling me it doesn't like any of the .NET images I'm
# trying to spin up in the default NS. Complaining about admission webook 
# "aks-webhook-admission-controller.azmk8s.io" does not support dry run. :shrug:
# https://github.com/Azure/AKS/issues/2197
# manually execute to 'fix': 

kubectl patch mutatingwebhookconfigurations.admissionregistration.k8s.io aks-webhook-admission-controller --type json -p='[{"op": "add", "path": "/webhooks/0/sideEffects", "value":"None"}]'

