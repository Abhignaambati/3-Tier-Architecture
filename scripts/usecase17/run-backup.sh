#!/usr/bin/env bash

set -euo pipefail

CONTEXT="${KUBE_CONTEXT:-docker-desktop}"
NAMESPACE="${KUBE_NAMESPACE:-backup-restore-lab}"

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  delete job usecase17-table-backup \
  --ignore-not-found

kubectl --context "$CONTEXT" \
  apply -f kubernetes/usecase17/table-backup-job.yaml

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  wait --for=condition=complete \
  job/usecase17-table-backup \
  --timeout=300s

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  logs job/usecase17-table-backup

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  delete job usecase17-table-upload \
  --ignore-not-found

kubectl --context "$CONTEXT" \
  apply -f kubernetes/usecase17/table-upload-job.yaml

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  wait --for=condition=complete \
  job/usecase17-table-upload \
  --timeout=300s

kubectl --context "$CONTEXT" \
  -n "$NAMESPACE" \
  logs job/usecase17-table-upload
