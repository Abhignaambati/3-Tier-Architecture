# Use Case 19: Define SLOs, Error Budget, and Alert Rules

## Goal

Define a measurable reliability objective for one user-facing path, implement
the metric and alert, simulate user impact, prove notification delivery, tune
noise, and verify recovery.

## Lab boundary

- Kubernetes context: docker-desktop
- Application namespace: slo-lab
- Monitoring namespace: slo-monitoring
- Branch: usecase/19-slo-error-budget-alerts
- User path: GET /api/claims

No shared or production resources were used.

## Tools used

- Kubernetes
- kubectl
- Docker
- Helm
- Application Prometheus metrics
- Prometheus
- PromQL
- promtool
- Grafana
- Alertmanager
- Git
- Runbook documentation

## Application metrics

The lab application exposes:

- `/health`
- `/api/claims`
- `/metrics`

Important metrics:

- `claims_http_requests_total`
- `claims_http_request_duration_seconds`
- `claims_application_start_total`

Prometheus discovered the application through a Kubernetes ServiceMonitor.

## Service Level Indicator

The SLI is the proportion of Claims API requests that do not return HTTP 5xx
responses.

    SLI = successful requests / total requests

## Service Level Objective

At least 99% of GET /api/claims requests should succeed over a rolling 30-day
period.

## Error budget

The allowed failure ratio is:

    100% - 99% = 1%

For every 10,000 requests, up to 100 requests may fail before the error budget
is exhausted.

The approximate continuous-availability equivalent for 30 days is 7 hours and
12 minutes. The primary objective in this lab is request-based.

## Alert rule

Alert name:

    ClaimsApiHighErrorRate

Condition:

- HTTP 5xx error ratio greater than 5%
- Condition remains true for 30 seconds
- Severity is critical
- Service is claims-slo-app
- Environment is lab

The alert uses a user-impacting error signal instead of CPU usage alone.

## Healthy baseline

Healthy traffic produced successful HTTP 200 responses. Prometheus confirmed:

- The application target was up.
- Custom application metrics were available.
- The alert rule was healthy and inactive.

## Controlled failure

The lab generated HTTP 503 responses using the lab-only query parameter:

    /api/claims?fail=true

The error ratio reached 1, meaning 100% of requests in the evaluation window
failed.

The alert transitioned through:

    inactive -> pending -> firing

Prometheus exposed the firing alert with the expected labels, and Alertmanager
received it through the usecase19-lab receiver.

## Recovery

Failure traffic was stopped and healthy HTTP 200 traffic was generated.

Verification included:

- Application health remained successful.
- The error ratio returned below the threshold.
- The Prometheus alert returned to inactive.
- The alert disappeared from Alertmanager.
- Grafana displayed the recovery.

## Noise tuning

Initially, the lab receiver also received unrelated Kubernetes alerts.

Alertmanager was updated so:

- The root route sends unrelated alerts to the null receiver.
- Only ClaimsApiHighErrorRate is routed to usecase19-lab.

This keeps the notification path focused on the user-facing SLO.

## Controlled problems and resolutions

### Missing namespace manifest

The application initially could not deploy because the slo-lab namespace did
not exist. The namespace manifest was created and applied before the
application resources.

### Local image unavailable to Kubernetes

The application image existed in Docker but was unavailable to the Kubernetes
node while imagePullPolicy was Never. The image was exported and imported into
the Docker Desktop Kubernetes node.

### Invalid Alertmanager receiver

The Operator reported:

    undefined receiver "null" used in route

The null receiver was explicitly defined in the Helm values, after which the
Alertmanager StatefulSet was created successfully.

### Stale Prometheus port-forward

An old port-forward retained port 9090 after the Prometheus pod was replaced.
A fresh port-forward was started on local port 19090.

### Empty ALERTS query

An inactive alert does not appear in the ALERTS metric. The Prometheus rules
API was used to verify that the rule was loaded, healthy, and inactive before
the controlled failure.

## Dashboard

The Grafana dashboard contains:

- Availability SLI
- HTTP error ratio
- P95 request latency
- Request rate
- Error-budget consumption

## Runbook

The alert runbook is located at:

    runbooks/usecase19/claims-api-high-error-rate.md

## Evidence

Command output and query results are stored in:

    usecase19-evidence/

Important evidence includes:

- Prometheus target proof
- Application metric proof
- Healthy traffic result
- SLI query
- promtool validation
- Alert state transition
- Prometheus firing alert
- Alertmanager firing alert
- Recovery proof
- Alert tuning note
- Effective Alertmanager configuration

## Interview answer

I define reliability in measurable terms. The SLI measures the success of a
user-facing path, the SLO establishes the target, and the error budget explains
how much failure is acceptable. I alert on sustained user-impacting errors,
verify delivery through Alertmanager, tune unrelated noise, and confirm the
alert resolves after recovery.
