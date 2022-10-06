#!/bin/bash

K8S_ENV=dev
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r .Account)
# kpt fn eval -i list-setters:v0.1.0

kpt fn eval -i apply-setters:v0.2.0 -- \
    environment=$K8S_ENV \
    account_id=$ACCOUNT_ID \
    nginx-replicas=2 \
    app-name=web

kpt fn eval -i set-namespace:v0.4.0 -- \
    namespace=$K8S_ENV-kpt

