#!/bin/bash

set -euo pipefail

export NAMESPACE=${NAMESPACE:-default}
export MINIKUBE_HOST=$(minikube ip)

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

helmfile sync --namespace "${NAMESPACE}" --environment minikube

echo "Deployment successful!"
echo "Run ./port-forward.sh to get in"
