#!/usr/bin/env bash

set -euo pipefail

export NAMESPACE=${NAMESPACE:-default}
MINIKUBE_HOST=$(minikube ip)
export MINIKUBE_HOST

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

helmfile sync --namespace "${NAMESPACE}" --environment minikube

echo ""
echo "Deployment successful!"
echo ""
echo "Run ./port-forward.sh to get in"
