# Claims API High Error Rate Runbook

## Alert

ClaimsApiHighErrorRate

## Service

claims-slo-app

## Environment

lab

## User impact

Users may receive HTTP 5xx responses when accessing:

GET /api/claims

## Reliability objective

At least 99% of Claims API requests should succeed over a rolling 30-day
period.

## Alert condition

The alert fires when the HTTP 5xx error ratio remains greater than 5% for
30 seconds.

## First three checks

### 1. Check the application workload

    kubectl --context docker-desktop \
      -n slo-lab \
      get deployment,pods,service,endpoints

Confirm that the Deployment is available, the pod is Ready, and the Service
has an endpoint.

### 2. Check application health

    kubectl --context docker-desktop \
      -n slo-lab \
      run temporary-health-check \
      --image=curlimages/curl:latest \
      --restart=Never \
      --rm -i \
      -- curl -s http://claims-slo-app/health

### 3. Check the error ratio in Prometheus

    sum(
      rate(
        claims_http_requests_total{
          path="/api/claims",
          status=~"5.."
        }[1m]
      )
    )
    /
    clamp_min(
      sum(
        rate(
          claims_http_requests_total{
            path="/api/claims"
          }[1m]
        )
      ),
      0.001
    )

## Additional investigation

Check application logs:

    kubectl --context docker-desktop \
      -n slo-lab \
      logs deployment/claims-slo-app \
      --since=10m

Check recent events:

    kubectl --context docker-desktop \
      -n slo-lab \
      get events \
      --sort-by=.lastTimestamp

Check recent deployment changes:

    kubectl --context docker-desktop \
      -n slo-lab \
      rollout history deployment/claims-slo-app

Review:

- HTTP status distribution
- Request rate
- P95 latency
- Pod readiness
- Recent deployments
- Dependency errors
- Error-budget consumption

## Mitigation

Possible mitigation depends on the evidence:

- Stop a controlled failure or bad traffic source.
- Roll back an unsafe application release.
- Restore an unavailable dependency.
- Correct invalid configuration.
- Restart or scale the application only when evidence supports it.

## Verification

After mitigation, confirm:

- The health endpoint returns HTTP 200.
- Successful requests are being recorded.
- The one-minute error ratio returns below 5%.
- ClaimsApiHighErrorRate changes to inactive.
- Alertmanager no longer shows the active alert.
- Grafana shows availability recovering.

## Escalation

Escalate when:

- The error ratio remains above 5% after mitigation.
- The root cause is an external dependency.
- The error budget continues to be consumed rapidly.
- Recovery requires a production or shared-resource change.
