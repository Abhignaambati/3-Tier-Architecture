import os
import time
from flask import Flask, jsonify, request, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

REQUESTS = Counter(
    "claims_http_requests_total",
    "Total Claims API requests",
    ["method", "path", "status"]
)

LATENCY = Histogram(
    "claims_http_request_duration_seconds",
    "Claims API request latency",
    ["method", "path"]
)

APP_INFO = Counter(
    "claims_application_start_total",
    "Claims application starts",
    ["service", "environment", "version"]
)

SERVICE = os.getenv("SERVICE_NAME", "claims-slo-app")
ENVIRONMENT = os.getenv("ENVIRONMENT", "lab")
VERSION = os.getenv("APP_VERSION", "1.0.0")

APP_INFO.labels(
    service=SERVICE,
    environment=ENVIRONMENT,
    version=VERSION
).inc()


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": SERVICE,
        "environment": ENVIRONMENT,
        "version": VERSION
    }), 200


@app.route("/api/claims")
def claims():
    start = time.time()
    path = "/api/claims"
    should_fail = request.args.get("fail", "false").lower() == "true"

    if should_fail:
        status = 503
        response = {
            "error": "Controlled Use Case 19 failure",
            "service": SERVICE,
            "environment": ENVIRONMENT,
            "version": VERSION
        }
    else:
        status = 200
        response = {
            "claims": [
                {
                    "id": 1901,
                    "status": "approved"
                }
            ],
            "service": SERVICE,
            "environment": ENVIRONMENT,
            "version": VERSION
        }

    REQUESTS.labels(
        method="GET",
        path=path,
        status=str(status)
    ).inc()

    LATENCY.labels(
        method="GET",
        path=path
    ).observe(time.time() - start)

    return jsonify(response), status


@app.route("/metrics")
def metrics():
    return Response(
        generate_latest(),
        mimetype=CONTENT_TYPE_LATEST
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
