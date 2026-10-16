# Use Case 9: Simulate an Incident and Recover

## Purpose

This lab demonstrates a controlled Kubernetes incident caused by a nonexistent container image. It covers detection, investigation, rollback, recovery verification, and incident documentation.

## Safety boundary

- Kubernetes context: docker-desktop
- Namespace: incident-lab
- Production resources: Not used
- Failure type: Invalid container image
- Production impact: None

## Deploy the healthy baseline

kubectl --context docker-desktop apply -f kubernetes/usecase9/claims-app.yaml

kubectl --context docker-desktop -n incident-lab rollout status deployment/claims-app --timeout=120s

kubectl --context docker-desktop -n incident-lab get pods,service,deployment

## Test the healthy endpoint

Start port-forwarding:

kubectl --context docker-desktop -n incident-lab port-forward service/claims-app 15010:80

Test the endpoint:

curl -i http://localhost:15010/health

## Introduce the controlled incident

Change the deployment to an invalid image:

kubectl --context docker-desktop -n incident-lab set image deployment/claims-app claims-app=nginx:usecase9-image-does-not-exist

## Investigate

kubectl --context docker-desktop -n incident-lab get pods

kubectl --context docker-desktop -n incident-lab describe deployment claims-app

kubectl --context docker-desktop -n incident-lab describe pods -l app=claims-app

kubectl --context docker-desktop -n incident-lab get events --sort-by=.lastTimestamp

kubectl --context docker-desktop -n incident-lab logs deployment/claims-app

## Recover

Rollback to the previous deployment revision:

kubectl --context docker-desktop -n incident-lab rollout undo deployment/claims-app

If the expected revision is unclear, explicitly restore the healthy image:

kubectl --context docker-desktop -n incident-lab set image deployment/claims-app claims-app=nginx:1.27-alpine

## Verify recovery

kubectl --context docker-desktop -n incident-lab rollout status deployment/claims-app --timeout=120s

kubectl --context docker-desktop -n incident-lab get deployment,pods,service

curl -i http://localhost:15010/health

## Evidence

Execution evidence is stored in the usecase9-evidence directory.

The incident report is:

usecase9-evidence/INCIDENT-REPORT.md

## Cleanup

kubectl --context docker-desktop delete namespace incident-lab

Run cleanup only after collecting all required screenshots and evidence.
