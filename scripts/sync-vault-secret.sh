#!/bin/zsh

set -e

ENVIRONMENT="$1"
NAMESPACE="$2"
VAULT_PATH="$3"

if [ -z "$ENVIRONMENT" ] || [ -z "$NAMESPACE" ] || [ -z "$VAULT_PATH" ]; then
  echo "Usage: $0 <environment> <namespace> <vault-path>"
  exit 1
fi

echo "Synchronizing the ${ENVIRONMENT} secret"
echo "Vault path: ${VAULT_PATH}"
echo "Kubernetes namespace: ${NAMESPACE}"

APP_USERNAME=$(vault kv get -field=username "$VAULT_PATH")
APP_PASSWORD=$(vault kv get -field=password "$VAULT_PATH")

kubectl --context docker-desktop \
  -n "$NAMESPACE" \
  create secret generic claims-app-secret \
  --from-literal=username="$APP_USERNAME" \
  --from-literal=password="$APP_PASSWORD" \
  --dry-run=client \
  -o yaml \
  | kubectl --context docker-desktop apply -f -

unset APP_USERNAME
unset APP_PASSWORD

echo "Secret synchronized successfully; secret values were not displayed."
