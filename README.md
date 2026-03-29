# OVMS CLI Demo - GSoC 2026 demo implementation

A minimal working demonstration for the **OpenVINO Model Server: One-Command Installer & Developer-Friendly CLI** GSoC.

---
## Here is the Live demo
[Live demo](https://youtu.be/a1_wDjDlpAw)
## https://youtu.be/a1_wDjDlpAw

[![Watch the video](https://i9.ytimg.com/vi/a1_wDjDlpAw/mqdefault.jpg?sqp=CKizo84G-oaymwEmCMACELQB8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGGEgSShyMA8=&rs=AOn4CLBf2dejw7KuHRkkCnGgfb2DhhWVIQ)](https://youtu.be/a1_wDjDlpAw)
---
Implementation:
A minimal working proof-of-concept for the **OpenVINO Model Server:
One-Command Installer & Developer-Friendly CLI** GSoC project (#19).
Made to demonstrate the final working of the project 

This demo proves two core ideas from the proposal:
1. A shell script can reliably detect OS + architecture and construct the correct OVMS download URL.
2. A Python script can poll the OVMS health endpoint and, once ready, drop into an interactive chat loop.


## Files

**`detect.sh`** — Detects the current OS (Ubuntu, RHEL, Debian) and CPU
architecture (amd64, arm64), then prints the correct OVMS package download
URL.

**`mock_server.py`** — A lightweight Flask server that mimics the two OVMS
endpoints used by the CLI: `/v2/health/ready` and
`/v3/chat/completions`. Made to demonstrate a simple working

**`health_chat.py`** — Polls `/v2/health/ready` every second until the server
is up, then opens an interactive chat REPL that sends messages to
`/v3/chat/completions` and prints the responses

---
