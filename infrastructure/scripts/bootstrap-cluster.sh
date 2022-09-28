#!/bin/bash

# test if helm fluxctl, linkerd exists
# bail if not
for p in fluxctl linkerd helm
do
    if ! hash $p 2>/dev/null
    then
        echo "$p was not found in PATH"
        exit 1
    fi
done;

aws eks update-kubeconfig --name $1

helm repo add fluxcd https://charts.fluxcd.io
helm repo add bitnami https://charts.bitnami.com
helm repo add flagger https://flagger.app
helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator

LINKERD_EXISTS=$(kubectl get namespaces --output name | grep linkerd)
FLUX_EXISTS=$(kubectl get namespaces --output name | grep fluxcd)
HELM_OPERATOR_EXISTS=$(kubectl --namespace fluxcd get deployments | grep helm-operator)
FLAGGER_EXISTS=$(kubectl --namespace linkerd get deployments | grep flagger)

# this caused problems with my first cluster - needed to execute sooner 
# (here, not after helm operator as in https://helm.workshop.flagger.dev/prerequisites/#linkerd)j

if test -z "$LINKERD_EXISTS" 
then
    linkerd install | kubectl apply -f -
fi
if test -z "$FLUX_EXISTS" 
then
    kubectl create ns fluxcd
fi

helm upgrade -i flux fluxcd/flux --wait \
  --namespace fluxcd \
  --set registry.pollInterval=2m \
  --set git.pollInterval=1m \
  --set git.email=bjameshunter@gmail.com \
  --set git.branch=$3 \
  --set git.url=$2 \

if test -z "$HELM_OPERATOR_EXISTS" 
then
    kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
fi
if test -z "$FLAGGER_EXISTS" 
then
    kubectl apply -f https://raw.githubusercontent.com/weaveworks/flagger/master/artifacts/flagger/crd.yaml
fi

helm upgrade -i helm-operator fluxcd/helm-operator --wait \
  --namespace fluxcd \
  --set git.ssh.secretName=flux-git-deploy \
  --set helm.versions=v3

helm upgrade -i flagger flagger/flagger --wait \
  --namespace linkerd \
  --set crd.create=false \
  --set metricsServer=http://linkerd-prometheus:9090 \
  --set meshProvider=linkerd
