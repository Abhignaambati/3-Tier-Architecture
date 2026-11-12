import hmac
import json
import os
import time
import uuid

from flask import Flask, Response, jsonify, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

app = Flask(__name__)

SERVICE_NAME = "claims-status-api"
ENVIRONMENT = os.getenv("APP_ENVIRONMENT", "dev")
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
APP_API_TOKEN = os.getenv("APP_API_TOKEN", "")

REQUESTS = Counter(
    "claims_status_http_requests_total",
    "Total HTTP requests",
    ["service", "environment", "version", "path", "method", "status"],
)

LATENCY = Histogram(
    "claims_status_http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["service", "environment", "version", "path"],
)


@app.before_request
def start_request_timer():
    request.start_time = time.time()
    request.request_id = request.headers.get(
        "X-Request-ID",
        str(uuid.uuid4()),
    )


@app.after_request
def record_request(response):
    path = request.url_rule.rule if request.url_rule else request.path
    duration = time.time() - request.start_time

    REQUESTS.labels(
        service=SERVICE_NAME,
        environment=ENVIRONMENT,
        version=APP_VERSION,
        path=path,
        method=request.method,
        status=str(response.status_code),
    ).inc()

    LATENCY.labels(
        service=SERVICE_NAME,
        environment=ENVIRONMENT,
        version=APP_VERSION,
        path=path,
    ).observe(duration)

    log_entry = {
        "level": "INFO",
        "service": SERVICE_NAME,
        "environment": ENVIRONMENT,
        "version": APP_VERSION,
        "request_id": request.request_id,
        "method": request.method,
        "path": path,
        "status": response.status_code,
        "duration_seconds": round(duration, 6),
        "message": "request completed",
    }

    print(json.dumps(log_entry), flush=True)

    response.headers["X-Request-ID"] = request.request_id
    return response


@app.route("/health")
def health():
    return jsonify(
        status="healthy",
        service=SERVICE_NAME,
        environment=ENVIRONMENT,
        version=APP_VERSION,
    )


@app.route("/api/status")
def status():
    return jsonify(
        service=SERVICE_NAME,
        environment=ENVIRONMENT,
        version=APP_VERSION,
        platform="ClaimsLab",
        message="ClaimsLab onboarding application is running",
    )


@app.route("/api/secure-status")
def secure_status():
    if not APP_API_TOKEN:
        return jsonify(error="Application secret is not configured"), 503

    authorization = request.headers.get("Authorization", "")
    supplied_token = authorization.removeprefix("Bearer ").strip()

    if not hmac.compare_digest(supplied_token, APP_API_TOKEN):
        return jsonify(error="Unauthorized"), 401

    return jsonify(
        status="authorized",
        service=SERVICE_NAME,
        secret_loaded=True,
    )


@app.route("/metrics")
def metrics():
    return Response(
        generate_latest(),
        mimetype=CONTENT_TYPE_LATEST,
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
