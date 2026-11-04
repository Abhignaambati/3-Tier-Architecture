# Use Case 18: Troubleshoot Logging Pipeline Failure

## Goal

Break and repair log collection and prove that structured application logs are searchable after recovery.

## Lab scope

- Kubernetes context: docker-desktop
- Namespace: logging-lab
- Application: claims-logger
- Collector: Grafana Alloy
- Destination: Loki
- Search interface: Grafana
- Deployment tools: Helm and kubectl

## Logging flow

Claims application -> Kubernetes logs -> Alloy -> Loki -> Grafana

## Healthy baseline

The application generated request UC18-BASELINE-001 with the message baseline-logging-pipeline-working. The structured log was visible in kubectl logs, Loki, and Grafana.

The log included service claims-backend, environment lab, version 1.0.0, request ID, status, level, timestamp, and message fields.

## Controlled failure

Alloy was scaled to zero replicas. The application then generated request UC18-MISSING-001.

The message appeared in kubectl logs but was not found in Loki while the collector was stopped. This proved the application was working and the failure occurred at the collection stage.

## Root cause

Grafana Alloy had no running replicas, so no collector was available to forward Kubernetes container logs to Loki.

## Recovery

Alloy was restored to one replica. After its rollout completed, the application generated request UC18-RECOVERED-001 with message logging-pipeline-recovered.

The recovery message appeared in Kubernetes logs, the Loki API, and Grafana Explore.

## Tools used

- Docker Desktop
- Kubernetes and kubectl
- Helm
- Flask structured logs
- Grafana Alloy
- Loki and LogQL
- Grafana
- curl

## Prevention

- Alert when Alloy has no ready replicas.
- Monitor Loki ingestion.
- Keep consistent service, environment, version, and request ID fields.
- Validate Helm values before deployment.
- Maintain a known-message logging test.

## Evidence

Command outputs and query results are stored in usecase18-evidence.

## Result

The logging failure was traced to the collector, repaired, and verified end to end using a new structured log message.

## Interview answer

I troubleshoot logging as a pipeline: the application emits, the collector reads, the destination stores, and the query proves searchability. I identify where a known message disappears, repair that stage, and generate a new message to prove recovery.
