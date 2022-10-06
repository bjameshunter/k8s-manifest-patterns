#!/bin/bash

K8S_ENV=dev
# kpt fn eval -i list-setters:v0.1.0

kpt fn eval -i apply-setters:v0.2.0 -- \
    environment=$K8S_ENV \
    nginx-replicas=2 \
    tech=kpt \
    app-name=web

kpt fn eval -i set-namespace:v0.4.0 -- \
    namespace=$K8S_ENV-kpt

