# Use Case 12 Secret Rotation Rollback

## Rollback trigger

Roll back when new pods fail readiness, authentication fails, or dependent requests fail after rotation.

## Procedure

1. Stop the new value from replacing additional healthy consumers.
2. Read the previous approved Vault version directly into a temporary shell variable.
3. Synchronize that value to the Kubernetes Secret without printing it.
4. Clear the shell variable immediately.
5. Restart or update the Deployment so new pods reload the restored value.
6. Wait for the rollout to complete.
7. Verify ready pods, HTTP health, and masked application logs.

## Success criteria

- The rollout completes.
- All desired pods are ready.
- The health endpoint returns HTTP 200.
- The expected secret version appears in masked evidence.
- No secret value appears in logs, screenshots, manifests, or Git.
