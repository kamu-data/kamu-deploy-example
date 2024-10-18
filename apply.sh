#!/bin/bash

set -euo pipefail

export NAMESPACE=${NAMESPACE:-default}

MINIKUBE_HOST=$(minikube ip)
export MINIKUBE_HOST

helmfile apply --namespace "${NAMESPACE}" --environment minikube

echo "Deployment successful!"
echo "Run ./port-forward.sh to get in"
