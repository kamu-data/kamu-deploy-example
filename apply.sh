#!/bin/bash

set -euo pipefail

export NAMESPACE=${NAMESPACE:-default}
export MINIKUBE_HOST=$(minikube ip)

helmfile apply --namespace "${NAMESPACE}" --environment minikube

echo "Deployment successful!"
echo "Run ./port-forward.sh to get in"
