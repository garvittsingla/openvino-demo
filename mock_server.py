"""
Mock OVMS Server for Testing
A simple Flask server that mimics OVMS endpoints for demo purposes.
"""

from flask import Flask, jsonify, request
import time

app = Flask(__name__)

# Simulate server startup delay
START_TIME = time.time()
STARTUP_DELAY = 5  # Server becomes "ready" after 5 seconds


@app.route("/v2/health/ready", methods=["GET"])
def health_ready():
    """Simulates the OVMS readiness endpoint."""
    if time.time() - START_TIME < STARTUP_DELAY:
        return jsonify({"status": "not ready"}), 503
    return jsonify({"status": "ready"}), 200


@app.route("/v3/chat/completions", methods=["POST"])
def chat_completions():
    """Simulates the OpenAI-compatible chat endpoint."""
    data = request.json
    messages = data.get("messages", [])
    
    # Simple echo response for demo
    last_message = messages[-1]["content"] if messages else "Hello"
    
    return jsonify({
        "choices": [{
            "message": {
                "role": "assistant",
                "content": f"[Mock Response] You said: {last_message}"
            }
        }]
    })


if __name__ == "__main__":
    print(f"Mock OVMS server starting...")
    print(f"Server will be 'ready' after {STARTUP_DELAY} seconds")
    print(f"Endpoints:")
    print(f"  - GET  http://localhost:8000/v2/health/ready")
    print(f"  - POST http://localhost:8000/v3/chat/completions")
    app.run(host="0.0.0.0", port=8000)
