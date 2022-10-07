#!/bin/bash

kubectl apply -f scripts/aws-load-balancer-controller-service-account.yaml
kubectl apply -f scripts/aws-ingress-controller.yaml
kubectl apply -f scripts/v2_4_4_ingclass.yaml


