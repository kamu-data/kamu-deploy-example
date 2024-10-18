#!/usr/bin/env bash

set -euo pipefail

export NAMESPACE=${NAMESPACE:-default}
MINIKUBE_HOST=$(minikube ip)
export MINIKUBE_HOST

service_node_port() {
    svc="$2"
    pname="$3"
    port=$(kubectl get \
      --ignore-not-found \
      --namespace "${NAMESPACE}" \
      -o jsonpath="{.spec.ports[?(@.name==\"$pname\")].nodePort}" \
      services "$svc" \
    )
    eval "$1='$port'"
}

service_node_port "KAMU_API_REST_PORT" "kamu-api-server" "http"
service_node_port "KAMU_API_FLIGHTSQL_PORT" "kamu-api-server" "flightsql"
service_node_port "KAMU_WEB_UI_PORT" "kamu-web-ui" "http"
service_node_port "JUPYTERHUB_PROXY_PORT" "proxy-public" "http"
service_node_port "SUPERSET_PORT" "superset" "http"
service_node_port "MINIO_API_PORT" "minio" "api"
service_node_port "MINIO_CONSOLE_PORT" "minio" "console"

if [ -n "$KAMU_API_REST_PORT" ]; then
    echo "================ Kamu Node ================"
    echo "REST / GraphQL:   http://$MINIKUBE_HOST:$KAMU_API_REST_PORT"
    echo "FlightSQL:        http://$MINIKUBE_HOST:$KAMU_API_FLIGHTSQL_PORT"
    echo ""
fi
if [ -n "$KAMU_WEB_UI_PORT" ]; then
    echo "=============== Kamu Web UI ==============="
    echo "Web UI (fwd):     http://localhost:4200"
    echo "Web UI:           http://$MINIKUBE_HOST:$KAMU_WEB_UI_PORT"
    echo ""
fi
if [ -n "$SUPERSET_PORT" ]; then
    echo "================ Superset ================="
    echo "Web UI (fwd):     http://localhost:4400"
    echo "Web UI:           http://$MINIKUBE_HOST:$SUPERSET_PORT"
    echo "Login / pwd:      kamu / kamu"
    echo ""
fi
if [ -n "$JUPYTERHUB_PROXY_PORT" ]; then
    echo "=============== JupyterHub ================"
    echo "Web UI (fwd):     http://localhost:4300"
    echo "Web UI:           http://$MINIKUBE_HOST:$JUPYTERHUB_PROXY_PORT"
    echo ""
fi
if [ -n "$MINIO_API_PORT" ]; then
    MINIO_USER=$(kubectl get --namespace "${NAMESPACE}" secret minio-creds -o jsonpath='{.data.root_user}' | base64 -d)
    MINIO_PASSWORD=$(kubectl get --namespace "${NAMESPACE}" secret minio-creds -o jsonpath='{.data.root_password}' | base64 -d)
    echo "================== Minio =================="
    echo "Minio API:        http://$MINIKUBE_HOST:$MINIO_API_PORT"
    echo "Minio Console:    http://$MINIKUBE_HOST:$MINIO_CONSOLE_PORT"
    echo "Username:         ${MINIO_USER}"
    echo "Password:         ${MINIO_PASSWORD}"
    echo ""
fi

jobs=
trap 'kill -HUP $jobs' INT TERM HUP
if [ -n "$KAMU_WEB_UI_PORT" ]; then
    kubectl port-forward service/kamu-web-ui 4200:http & jobs="$jobs $!"
fi
if [ -n "$SUPERSET_PORT" ]; then
    kubectl port-forward service/superset 4400:http & jobs="$jobs $!"
fi
if [ -n "$JUPYTERHUB_PROXY_PORT" ]; then
    kubectl port-forward service/proxy-public 4300:http & jobs="$jobs $!"
fi

sleep 1
echo "Press Ctrl+C to exit"
wait
