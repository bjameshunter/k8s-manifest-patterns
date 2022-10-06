#!/bin/bash

K8S_ENV=dev
# kpt fn eval -i list-setters:v0.1.0

# kpt fn eval -i apply-setters:v0.2.0 -- \
#     environment=dev \
#     nginx-replicas=2 \
#     namespace=kpt-dev \
#     app-name=web
#
kpt fn eval -i set-namespace:v0.4.0 -- \
    namespace=kpt-$K8S_ENV

