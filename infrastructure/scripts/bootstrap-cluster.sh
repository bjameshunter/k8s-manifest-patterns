#!/bin/bash

GIT_REPO=https://github.com/bjameshunter/k8s-manifest-patterns.git
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r .Account)

aws eks update-kubeconfig --name $1

cat >scripts/aws-load-balancer-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${ACCOUNT_ID}:role/eks-$1-ingress
EOF

kubectl apply -f scripts/aws-ingress-controller.yaml
kubectl apply -f scripts/aws-load-balancer-controller-service-account.yaml
kubectl apply -f scripts/v2_4_4_ingclass.yaml

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
kubectl apply -k "../flux/clusters/base"

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

