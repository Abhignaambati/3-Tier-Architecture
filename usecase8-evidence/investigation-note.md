# Use Case 8 Incident Investigation Note

## Incident symptom

Users report that the Claims application is unavailable.

## First three checks

### 1. Application health

Commands:
curl -i http://localhost:5009/api/health
docker compose ps backend

Purpose:
Confirm whether the backend process is running and its health endpoint responds.

### 2. Prometheus availability metric

PromQL query:
up{job="claims-backend"}

Purpose:
A value of 1 means Prometheus can scrape the backend.
A value of 0 means the backend is unavailable.

### 3. Backend logs

LogQL query:
{service="backend", environment="lab", version="1.0.0"}

Error search:
{service="backend", environment="lab", version="1.0.0"} |= "404"

Purpose:
Search backend requests and errors using service, environment, and version labels.

## Controlled failure

The backend was stopped with:
docker compose stop backend

Prometheus reported the backend as unavailable.
The ClaimsBackendUnavailable alert entered the firing state and appeared in Alertmanager.

## Recovery

The backend was restarted with:
docker compose start backend

The health endpoint recovered, the Prometheus up metric returned to 1, and the alert resolved.

## Conclusion

The investigation connected the user symptom to the health endpoint, Prometheus metrics, alert state, and centralized logs.
