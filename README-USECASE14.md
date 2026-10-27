# Use Case 14: Blue-Green Deployment

## Goal

Release a new application version with controlled exposure and demonstrate a fast rollback path.

## Lab boundary

- Kubernetes context: `docker-desktop`
- Namespace: `blue-green-lab`
- Production-like Service: `claims-app`
- Preview Service: `claims-app-preview`
- Stable Deployment: `claims-blue`
- Candidate Deployment: `claims-green`
- Stable application version: `blue-v1`
- Candidate application version: `green-v2`

Only local Docker Desktop Kubernetes resources were used. No production or shared resources were changed.

## Tools used

- Docker Desktop
- Kubernetes
- kubectl
- NGINX
- curl
- Git
- GitHub
- GitLab

## Architecture

The lab used two application Deployments that ran simultaneously:

- `claims-blue` represented the stable version.
- `claims-green` represented the candidate version.
- `claims-app` represented production-like traffic.
- `claims-app-preview` provided a separate testing path to green.

The production Service selected only one application version at a time:

```text
claims-app
    |
    +-- version: blue
    |
    +-- version: green
```

Traffic was moved without rebuilding the application. Only the Kubernetes Service selector changed.

## Files

- `kubernetes/usecase14/namespace.yaml`: isolated lab namespace
- `kubernetes/usecase14/blue-green.yaml`: blue and green Deployments, ConfigMaps, and Services
- `kubernetes/usecase14/deployment-bad.yaml`: deliberately invalid release
- `usecase14-evidence/`: command output and completion evidence

## Namespace

The following namespace isolated the lab:

```text
blue-green-lab
```

This prevented the exercise from affecting workloads in other namespaces.

## Blue stable version

The blue Deployment used:

```text
Deployment: claims-blue
Label: version=blue
Application version: blue-v1
Replicas: 2
```

Both blue replicas reached the Running and Ready state.

The production Service initially selected blue:

```text
Production selector: blue
```

The production endpoints returned:

```text
Version: blue-v1
Health: healthy
```

This established the known-good baseline.

## Green candidate version

The green Deployment used:

```text
Deployment: claims-green
Label: version=green
Application version: green-v2
Replicas: 2
```

Both green replicas reached the Running and Ready state.

Before production traffic was changed, green was tested through the preview Service:

```text
claims-app-preview
```

The preview endpoints returned:

```text
Version: green-v2
Health: healthy
```

The logs also showed HTTP `200` responses for:

- Kubernetes readiness probes
- Kubernetes liveness probes
- `/version` requests
- `/health` requests

This proved that green was healthy before receiving production-like traffic.

## Production traffic switch

Production traffic was moved from blue to green by changing the production Service selector:

```bash
kubectl --context docker-desktop \
  -n blue-green-lab \
  patch service claims-app \
  -p '{"spec":{"selector":{"app":"claims-app","version":"green"}}}'
```

After the switch, the selector showed:

```text
Production selector: green
```

The production endpoint then returned:

```text
Version: green-v2
Health: healthy
```

The blue Deployment was not removed. It remained running as the known-good rollback target.

## Why the traffic switch was low risk

The new version was validated before the switch.

The following checks were completed:

1. Green Deployment rollout completed.
2. Both green pods were Ready.
3. The preview version endpoint returned `green-v2`.
4. The preview health endpoint returned `healthy`.
5. Green logs showed successful HTTP requests.
6. The blue Deployment remained available.

Because both versions ran simultaneously, moving traffic did not require rebuilding or restarting the stable version.

## Controlled bad release

A separate bad Deployment was created using a nonexistent image:

```text
nginx:usecase14-image-does-not-exist
```

The bad pods could not download the image.

Kubernetes reported states such as:

```text
ErrImagePull
ImagePullBackOff
```

The pod description and events showed that the image could not be pulled.

Because the bad pods were not Ready, they were not safe to receive production traffic.

## Controlled traffic failure

For troubleshooting practice, the production Service was temporarily pointed to:

```text
version: bad
```

The bad version had no Ready application endpoints.

The production request failed, demonstrating the user impact that would occur if traffic were switched without checking readiness, health, events, and endpoint availability.

The failure was limited to the local `blue-green-lab` namespace.

## Rollback

Production traffic was restored by changing the Service selector back to blue:

```bash
kubectl --context docker-desktop \
  -n blue-green-lab \
  patch service claims-app \
  -p '{"spec":{"selector":{"app":"claims-app","version":"blue"}}}'
```

After rollback, the selector showed:

```text
Production selector after rollback: blue
```

The production endpoints returned:

```text
Version: blue-v1
Health: healthy
```

The bad Deployment was deleted after recovery.

## Application impact

The normal blue-to-green switch did not interrupt the application because green was healthy before receiving traffic.

The controlled bad switch temporarily made the production-like Service unavailable because it selected pods that were not Ready.

Recovery did not require:

- Changing application code
- Rebuilding an image
- Restarting the blue Deployment
- Deleting the green Deployment

Recovery only required changing the Service selector back to the known-good blue version.

## Signals that would stop a real rollout

A real rollout should stop or roll back when any of these signals appear:

- Readiness checks fail
- Liveness checks fail
- Health endpoint returns a non-200 response
- HTTP error rate increases
- Request latency increases
- Pod restart count increases
- Kubernetes events show image-pull failures
- Logs contain repeated application errors
- Important user operations fail
- CPU or memory usage exceeds safe limits
- The new version has no Ready Service endpoints

A rollout should continue only when the candidate version is healthy and user-impacting behavior remains acceptable.

## Evidence

Evidence was saved in `usecase14-evidence/`.

Important evidence includes:

- Namespace creation output
- Client-side dry-run result
- Server-side dry-run result
- Blue rollout status
- Green rollout status
- Initial Kubernetes resource status
- Initial production selector
- Blue version response
- Blue health response
- Green preview version response
- Green preview health response
- Production switch to green
- Production green selector
- Green endpoint proof
- Production green version response
- Production green health response
- Green access logs
- Bad Deployment creation
- Bad pod status
- Bad pod description
- Kubernetes failure events
- Production switch to the bad version
- Empty or unavailable bad-version endpoints
- Failed production request
- Rollback command
- Selector after rollback
- Blue version after rollback
- Health response after rollback
- Final Kubernetes resource state
- Lab completion timestamps

## Result

Use Case 14 successfully demonstrated:

1. Deploying stable and candidate versions simultaneously
2. Keeping production traffic on the stable version
3. Testing the candidate through a preview Service
4. Comparing health, logs, endpoints, and workload state
5. Moving production traffic to the candidate version
6. Proving the production endpoint returned the new version
7. Creating a controlled bad release
8. Observing image-pull and readiness failures
9. Demonstrating the impact of an unsafe traffic switch
10. Rolling traffic back to the stable version
11. Verifying application health after rollback
12. Saving evidence and documenting the recovery path

## Git branch

All Use Case 14 work was stored on:

```text
usecase/14-blue-green-deployment
```

The Use Case 14 files were kept separate from the `main` branch.

## Interview explanation

I reduce release risk by running stable and candidate versions simultaneously. I test the candidate through a separate preview path before changing production traffic. I check rollout status, readiness, health, endpoints, logs, error behavior, latency, restarts, and user-impacting operations.

In this lab, I moved traffic by changing a Kubernetes Service selector from blue to green. I also created a controlled bad release with an invalid image. When the production-like Service selected the bad version, it had no healthy endpoints. I recovered the application by changing the Service selector back to the known-good blue version. This provided a fast rollback without rebuilding or modifying application code.
