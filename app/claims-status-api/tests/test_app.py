import sys
from pathlib import Path

APP_DIRECTORY = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(APP_DIRECTORY))

from app import app


def test_health_endpoint():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json()["status"] == "healthy"
    assert response.get_json()["service"] == "claims-status-api"


def test_status_endpoint():
    client = app.test_client()
    response = client.get("/api/status")

    assert response.status_code == 200
    assert response.get_json()["platform"] == "ClaimsLab"


def test_metrics_endpoint():
    client = app.test_client()
    response = client.get("/metrics")

    assert response.status_code == 200
    assert b"claims_status_http_requests_total" in response.data


def test_secure_endpoint_requires_secret():
    client = app.test_client()
    response = client.get("/api/secure-status")

    assert response.status_code in [401, 503]
