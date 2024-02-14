#!/bin/bash

set -euo pipefail

export NAMESPACE=${NAMESPACE:-default}
export MINIKUBE_HOST=$(minikube ip)

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

helmfile sync --namespace "${NAMESPACE}" --environment minikube

KAMU_API_PORT=$(kubectl get --namespace ${NAMESPACE} -o jsonpath="{.spec.ports[0].nodePort}" services kamu-api-server)
KAMU_WEB_UI_PORT=$(kubectl get --namespace ${NAMESPACE} -o jsonpath="{.spec.ports[0].nodePort}" services kamu-web-ui)
MINIO_API_PORT=$(kubectl get --namespace "${NAMESPACE}" -o jsonpath="{.spec.ports[0].nodePort}" services minio)
MINIO_CONSOLE_PORT=$(kubectl get --namespace "${NAMESPACE}" -o jsonpath="{.spec.ports[1].nodePort}" services minio)
MINIO_USER=$(kubectl get --namespace "${NAMESPACE}" secret minio-creds -o jsonpath='{.data.root_user}' | base64 -d)
MINIO_PASSWORD=$(kubectl get --namespace "${NAMESPACE}" secret minio-creds -o jsonpath='{.data.root_password}' | base64 -d)

echo '==========================================================='
echo '                      KAMU                                 '
echo '-----------------------------------------------------------'
echo "Kamu API:         http://$MINIKUBE_HOST:$KAMU_API_PORT"
echo "Kamu Web UI:      http://$MINIKUBE_HOST:$KAMU_WEB_UI_PORT"
echo ''
echo '==========================================================='
echo '                      MINIO                                '
echo '-----------------------------------------------------------'
echo "Minio API:        http://$MINIKUBE_HOST:$MINIO_API_PORT"
echo "Minio Console:    http://$MINIKUBE_HOST:$MINIO_CONSOLE_PORT"
echo "Username:         ${MINIO_USER}"
echo "Password:         ${MINIO_PASSWORD}"
echo ''
echo '==========================================================='
