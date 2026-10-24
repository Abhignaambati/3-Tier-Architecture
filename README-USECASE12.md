# Use Case 12 Rotate Secrets Without Breaking the App

## Objective

Rotate a lab-only application token stored in Vault, synchronize it to a Kubernetes Secret, restart consumers safely, and verify application health without exposing the secret value.

## Lab boundary

- Vault path: `secret/midhlab/usecase12/app`
- Kubernetes namespace: `secret-rotation-lab`
- Kubernetes Secret: `app-credentials`
- Deployment: `claims-secret-app`
- Secret key: `app-token`

Only local training resources were used.

## Application reference

The Deployment reads the value through `secretKeyRef`. The application validates the secret during startup but logs only the validation result and Vault version. It never logs the value.

## Initial baseline

Vault version 1 contained a valid lab token. It was synchronized to the Kubernetes Secret, and both application replicas became ready. The health endpoint returned `healthy` with secret version 1.

## Controlled failure

Vault version 2 contained a deliberately invalid lab value. After synchronization and rollout, the replacement pod failed its readiness probe with HTTP 503. The rolling-update strategy kept the previous ready pods available, so service traffic continued to receive a healthy version 1 response.

## Rollback

Vault version 1 was read directly into a temporary shell variable, synchronized back to Kubernetes, and immediately cleared from the shell. After the rollout, all pods became ready and the health endpoint returned version 1.

## Successful rotation

Vault version 3 contained a valid replacement value. Kubernetes was updated, the Deployment restarted, both replicas became ready, and the health endpoint returned version 3.

## Evidence

The `usecase12-evidence` directory contains:

- Vault status and secret-engine output
- Masked Vault write metadata for versions 1, 2, and 3
- Initial rollout and health proof
- Invalid rollout status, pod state, events, and masked validation logs
- Rollback rollout and health proof
- Successful final rollout
- Final pod state and health response
- Final Vault version metadata
- Kubernetes secret-reference proof
- Completion timestamps

## Security controls

- Values were generated locally and stored in shell variables.
- Values were never printed or written to manifests.
- Variables were cleared immediately after synchronization.
- Kubernetes Secret data was not exported.
- Vault evidence contains metadata and versions only.
- Application logs contain validation status and version only.
- Credential-pattern scanning was performed before committing.

## Result

The lab demonstrated a controlled secret failure, a successful rollback, and a valid final rotation. The application remained available during the invalid rollout and finished healthy on Vault version 3.

## Interview answer

I rotate secrets by identifying consumers first, updating the approved secret store, synchronizing the consumer reference, restarting safely, and testing the application path that depends on the secret. I keep evidence masked and maintain a tested rollback to the previous approved version.
