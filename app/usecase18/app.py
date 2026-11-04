from datetime import datetime, timezone
from flask import Flask, jsonify, request
import json
import uuid

app = Flask(__name__)

SERVICE = "claims-backend"
ENVIRONMENT = "lab"
VERSION = "1.0.0"


def write_log(level, message, request_id, status):
    entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "level": level,
        "service": SERVICE,
        "environment": ENVIRONMENT,
        "version": VERSION,
        "request_id": request_id,
        "status": status,
        "message": message,
    }

    print(json.dumps(entry), flush=True)


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": SERVICE,
        "version": VERSION,
    })


@app.route("/generate-log")
def generate_log():
    request_id = request.args.get("request_id", str(uuid.uuid4()))
    message = request.args.get(
        "message",
        "Known Use Case 18 log message"
    )
    level = request.args.get("level", "INFO").upper()

    write_log(
        level=level,
        message=message,
        request_id=request_id,
        status=200,
    )

    return jsonify({
        "logged": True,
        "request_id": request_id,
        "service": SERVICE,
        "environment": ENVIRONMENT,
        "version": VERSION,
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
