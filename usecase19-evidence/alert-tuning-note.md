# Use Case 19 Alert Tuning Note

## Initial condition

The Claims API alert initially used a user-facing HTTP error-ratio signal:

- Alert: ClaimsApiHighErrorRate
- Threshold: greater than 5%
- Duration: 30 seconds
- Severity: critical
- Service: claims-slo-app
- Environment: lab

## Controlled test

Controlled HTTP 503 responses were generated against:

    GET /api/claims?fail=true

The measured one-minute error ratio reached:

    1.0

This represents a 100% failure ratio in the evaluation window.

The Prometheus rule changed through:

    inactive -> pending -> firing

Alertmanager successfully received the firing alert.

## Noise discovered

The initial Alertmanager root route sent unrelated Kubernetes alerts to the
same usecase19-lab receiver.

Examples included:

- Clock synchronization warnings
- Kubernetes control-plane target warnings
- CPU throttling alerts
- Default target-down alerts

These alerts were not related to the Claims API SLO and created unnecessary
noise.

## Routing correction

Alertmanager was tuned so that:

- The default root receiver is null.
- Only ClaimsApiHighErrorRate is sent to usecase19-lab.
- Unrelated platform alerts do not use the Use Case 19 receiver.

## Threshold decision

The final alert remains:

- Error ratio greater than 5%
- Condition sustained for 30 seconds

The duration prevents one isolated failed request from immediately generating
an alert.

The threshold remains sensitive enough for the lab because a sustained 5xx
ratio above 5% indicates likely user impact.

## Why CPU was not selected

CPU usage is an internal infrastructure signal. High CPU does not always mean
users are receiving errors.

The HTTP 5xx ratio directly measures unsuccessful user requests, so it is more
appropriate for protecting the availability SLO.

## Recovery result

After controlled failure traffic was stopped and healthy traffic resumed:

- The error ratio fell below the threshold.
- The rule returned to inactive.
- The alert resolved in Alertmanager.
- The application remained healthy.
