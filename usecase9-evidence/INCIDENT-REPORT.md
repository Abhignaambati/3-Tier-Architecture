# Use Case 9 Incident Report

## Incident title

Claims application unavailable because of an invalid container image.

## Environment

- Kubernetes context: docker-desktop
- Namespace: incident-lab
- Deployment: claims-app
- Service: claims-app
- Scope: Local training environment
- Production impact: None

## Incident summary

The Claims application became unavailable after its Kubernetes deployment was changed to use a nonexistent container image.

Kubernetes could schedule the pods, but it could not download the image. The pods remained unavailable with ErrImagePull and ImagePullBackOff.

The service was recovered by restoring the working nginx:1.27-alpine image.

## User impact

Users could not access the Claims application or its health endpoint because no application pod was ready.

## Detection

The incident was detected using:

- Failed health endpoint request
- Deployment rollout timeout
- Kubernetes pod status
- Deployment description
- Pod description
- Kubernetes events
- Container image inspection

## Timeline

- 2026-10-16 15:17:44 IST — Incident started.
- Healthy image nginx:1.27-alpine was replaced with nginx:usecase9-image-does-not-exist.
- Kubernetes created two replacement pods.
- Pods entered ErrImagePull and ImagePullBackOff.
- The application health endpoint became unavailable.
- Deployment, pod, event, image, and log evidence was collected.
- 2026-10-16 15:22:45 IST — Service was recovered.
- The working nginx:1.27-alpine image was restored.
- Both replicas returned to Running and Ready.
- The health endpoint returned HTTP 200.
- A second accidental rollback was corrected by explicitly setting nginx:1.27-alpine.

## Investigation

The first check was the Kubernetes pod status.

Both pods were Pending and not ready. Pod descriptions showed that the containers were waiting because Kubernetes could not pull nginx:usecase9-image-does-not-exist.

The ConfigMap, service account, scheduling, network identity, and volume configuration were available. The container never started, so application logs were unavailable during the incident.

This evidence showed that the failure happened before the application code could run.

## Root cause

The deployment referenced a nonexistent container image:

nginx:usecase9-image-does-not-exist

Kubernetes could not download that image. Therefore, the application containers could not start.

The application source code was not the cause.

## Recovery

The deployment was initially recovered using:

kubectl rollout undo deployment/claims-app

After an accidental second rollback, the final healthy image was explicitly restored using:

kubectl set image deployment/claims-app claims-app=nginx:1.27-alpine

## Recovery verification

Recovery was verified by confirming:

- Deployment rollout completed
- Two pods were Running
- Two pods were Ready
- Image was nginx:1.27-alpine
- Health endpoint returned HTTP 200
- Application page was accessible
- Container logs were available

## Prevention

1. Validate that a container image exists before deployment.
2. Use immutable image digests for controlled releases.
3. Add image validation to the CI pipeline.
4. Monitor rollout status automatically.
5. Alert when a deployment has unavailable replicas.
6. Use staged or canary deployments in production.
7. Document the exact recovery revision before running rollback commands.

## Evidence

Evidence is stored in the usecase9-evidence directory. It includes healthy baseline output, failed rollout output, pod descriptions, events, rollback output, final Kubernetes state, health checks, logs, and timestamps.

## Interview answer

I started with user impact and checked the health endpoint, rollout status, pod state, events, image configuration, and logs. The pods showed ImagePullBackOff because the deployment referenced a nonexistent image. I restored the working image without changing application code, verified both replicas and the health endpoint, and documented image validation as the prevention action.
