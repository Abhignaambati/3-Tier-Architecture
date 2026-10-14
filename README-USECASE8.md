# Use Case 8: Observe, Alert, and Investigate the Claims App

## Goal

Connect application health, Prometheus metrics, Grafana dashboards, Loki logs, and Alertmanager so an application failure can be detected and investigated.

## Components

- Claims Flask backend
- PostgreSQL
- Prometheus
- Grafana
- Loki
- Grafana Alloy
- Alertmanager

## Start the lab

Create the local environment file:

cp .env.example .env

Edit .env and provide local lab passwords.

Start the services:

docker compose up -d --build

Check the services:

docker compose ps

## Service URLs

Backend health:
http://localhost:5009/api/health

Backend metrics:
http://localhost:5009/metrics

Prometheus:
http://localhost:9090

Prometheus targets:
http://localhost:9090/targets

Prometheus alerts:
http://localhost:9090/alerts

Alertmanager:
http://localhost:9093

Grafana:
http://localhost:3000

Loki:
http://localhost:3100/ready

## Prometheus queries

Backend availability:

up{job="claims-backend"}

Request rate:

sum(rate(flask_http_request_total[1m]))

HTTP error rate:

sum(rate(flask_http_request_total{status=~"4..|5.."}[1m]))

95th-percentile latency:

histogram_quantile(0.95, sum(rate(flask_http_request_duration_seconds_bucket[5m])) by (le))

## Loki query

Backend errors:

{container="claims-usecase8-backend"} |= "404"

## Controlled alert test

Stop the backend:

docker compose stop backend

Wait at least 30 seconds and check Prometheus and Alertmanager.

Recover the backend:

docker compose start backend

Verify recovery:

curl http://localhost:5009/api/health

## Stop the lab

docker compose down

To remove the lab data as well:

docker compose down -v
