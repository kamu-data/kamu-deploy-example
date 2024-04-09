#!/bin/bash

set -euo pipefail

S3_EXAMPLE_REPO_URL="s3://datasets.kamu.dev/odf/v2/example-mt/"
MINO_BUCKET_NAME="datasets"
TMP_DIR=".tmp"

NAMESPACE=${NAMESPACE:-default}
MINIKUBE_HOST=$(minikube ip)

MINIO_API_PORT=$(kubectl get --namespace "${NAMESPACE}" -o jsonpath="{.spec.ports[0].nodePort}" services minio)
MINIO_USER=$(kubectl get --namespace "${NAMESPACE}" secret minio-creds -o jsonpath='{.data.root_user}' | base64 -d)
MINIO_PASSWORD=$(kubectl get --namespace "${NAMESPACE}" secret minio-creds -o jsonpath='{.data.root_password}' | base64 -d)

# Download example repo from public S3 bucket
rm -rf $TMP_DIR && mkdir $TMP_DIR
aws s3 cp --no-sign-request --recursive ${S3_EXAMPLE_REPO_URL} $TMP_DIR/

# Upload repo data to local Minio
AWS_ACCESS_KEY_ID=$MINIO_USER \
AWS_SECRET_ACCESS_KEY=$MINIO_PASSWORD \
AWS_SESSION_TOKEN="" \
aws \
    --endpoint-url "http://${MINIKUBE_HOST}:${MINIO_API_PORT}" \
    s3 cp --recursive $TMP_DIR/ "s3://${MINO_BUCKET_NAME}/"

# Clean up
rm -rf .tmp
