#!/usr/bin/env bash

set -euo pipefail

CONTEXT="${KUBE_CONTEXT:-docker-desktop}"
NAMESPACE="${KUBE_NAMESPACE:-backup-restore-lab}"

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  delete job usecase17-minio-download \
  --ignore-not-found

kubectl --context "$CONTEXT" \
  apply -f kubernetes/usecase17/minio-download-job.yaml

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  wait --for=condition=complete \
  job/usecase17-minio-download \
  --timeout=300s

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  logs job/usecase17-minio-download

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  delete job usecase17-postgres-restore \
  --ignore-not-found

kubectl --context "$CONTEXT" \
  apply -f kubernetes/usecase17/restore-job.yaml

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  wait --for=condition=complete \
  job/usecase17-postgres-restore \
  --timeout=300s

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  logs job/usecase17-postgres-restore
