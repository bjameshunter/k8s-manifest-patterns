#!/bin/bash

GIT_REPO=https://github.com/bjameshunter/k8s-manifest-patterns.git

aws eks update-kubeconfig --name $1

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/aws/deploy.yaml

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml

# install kpt crds
kpt live install-resource-group

# install argocd crds
# --we're using --insecure
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# flux
# makes a lot of required CRDs, deployments, etc for Flux
kubectl apply -k "../../flux/clusters/"

# point flux at our K8s repo and branch, define how often it checks
# for new commit, etc.
flux create source git flux-system \
  --git-implementation=libgit2 \
  --url="$GIT_REPO" \
  --username="bjameshunter@gmail.com" \
  --password="$GITHUB_TOKEN" \
  --branch="main" \
  --interval=60s

# create a 'kustomization', which is a CRD in the flux-system namespace
# that points to a directory with yaml files containing the instances
# of the CRDs
flux create kustomization flux-system-dev \
  --source=flux-system \
  --path="./flux/clusters/development" \
  --prune=true \
  --interval=60s

flux create kustomization flux-system-prod \
  --source=flux-system \
  --path="./flux/clusters/production" \
  --prune=true \
  --interval=60s

