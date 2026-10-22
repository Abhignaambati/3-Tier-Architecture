# Use Case 11: Fix ImagePullBackOff and Registry Access

## Objective

Diagnose and recover a Kubernetes deployment that cannot pull its container image. This lab practices two common causes: a missing image tag and a missing pull secret for a private Harbor registry.

## Lab boundary

- Kubernetes context: `docker-desktop`
- Namespace: `imagepull-lab`
- Deployment: `claims-app`
- Harbor project: `usecase11`
- Harbor repository: `claims-app`
- Harbor image tag: `1.0`

Only local lab resources were used.

## Tools

- Docker Desktop
- Kubernetes and kubectl
- Docker CLI
- Harbor container registry

## Healthy baseline

The application was initially deployed with `nginx:1.27-alpine`. Two pods reached `Running`, passed their readiness probes, and `/health` returned `healthy`. This established that Kubernetes, the Service, networking, and readiness configuration worked before failures were introduced.

## Failure 1: invalid image tag

The deployment image was changed to `nginx:usecase11-tag-does-not-exist`. The replacement pod entered `ErrImagePull` and then `ImagePullBackOff`.

The investigation used:

```bash
kubectl -n imagepull-lab get pods
kubectl -n imagepull-lab describe pod POD_NAME
kubectl -n imagepull-lab get events --sort-by=.lastTimestamp
docker manifest inspect nginx:usecase11-tag-does-not-exist
```

The pod events and registry check showed that the requested image tag did not exist.

### Recovery

The image was restored to `nginx:1.27-alpine`. The rollout completed, both replicas became ready, and `/health` returned `healthy`.

## Harbor preparation

A private Harbor project named `usecase11` was created. The valid image was pushed as `harbor.example.com:80/usecase11/claims-app:1.0`.

Harbor uses HTTP only for this local lab. Docker and the local Kubernetes node were configured to reach the registry. Harbor health returned HTTP 200 and the pushed image produced a manifest digest.

## Failure 2: missing imagePullSecret

The deployment was changed to the valid private Harbor image without an `imagePullSecrets` entry. The replacement pod entered `ErrImagePull` or `ImagePullBackOff`, and its events reported an authentication or authorization failure.

The image existed and Harbor was reachable. The failure occurred because the private project required credentials and the workload had no pull-secret reference.

## Secret recovery

The `harborpull` secret was created interactively so the password was not written to a manifest or committed to Git:

```bash
read -s "HARBOR_PASSWORD?Enter Harbor password: "
echo
kubectl -n imagepull-lab create secret docker-registry harborpull \
  --docker-server=harbor.example.com:80 \
  --docker-username=admin \
  --docker-password="$HARBOR_PASSWORD"
unset HARBOR_PASSWORD
```

Only the secret name and type were saved as evidence. The secret contents were not exported.

The Deployment was patched to reference:

```yaml
imagePullSecrets:
  - name: harborpull
```

## Final verification

The recovered deployment used:

```text
Image: harbor.example.com:80/usecase11/claims-app:1.0
Pull secret: harborpull
```

Verification included rollout status, pod readiness, deployment description, event history, and the `/health` response. Both replicas became ready and the endpoint returned `healthy`.

## Evidence

The `usecase11-evidence/` directory contains:

- Healthy baseline apply, rollout, pod, and health output
- Invalid-tag pod state, pod description, events, and registry check
- Corrected-tag rollout and health proof
- Harbor status, health, image push, and manifest proof
- Missing-secret pod state, pod description, and events
- Masked pull-secret proof
- Fixed image and pull-secret reference
- Final workload state, rollout, events, and health response
- Failure and recovery timestamps

## Troubleshooting method

For `ImagePullBackOff`:

1. Check pod status.
2. Describe the failing pod and read its Events section.
3. Confirm the full registry hostname, repository, image, and tag.
4. Confirm registry reachability.
5. Confirm that the image and tag exist.
6. Check for a registry secret in the workload namespace.
7. Confirm that the pod template references the correct secret.
8. Correct the identified cause.
9. Watch the rollout and verify readiness.

## Prevention

- Validate image tags before deployment.
- Push images before changing workloads.
- Prefer immutable tags or image digests.
- Create pull secrets in the correct namespace.
- Reference the correct secret in the pod specification.
- Monitor Kubernetes warning events.
- Never store registry passwords in YAML or Git.
- Use HTTPS and trusted certificates outside local labs.

## Interview answer

For `ImagePullBackOff`, I read Kubernetes events first. I then check the full image name and tag, registry availability, whether the image exists, registry authentication, the pull secret, and its namespace binding. In this lab, I diagnosed both a nonexistent tag and a missing Harbor pull secret, corrected each cause, watched the rollout, and verified that the pods passed readiness.
