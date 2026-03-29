"""
OVMS Health Check and Chat Demo
Polls the OVMS readiness endpoint, then opens an interactive chat loop.
"""

import time
import httpx

BASE_URL = "http://localhost:8000"


def wait_for_ready(timeout: int = 60) -> None:
    """
    Polls /v2/health/ready every second until the server responds 200,
    or raises an error after 'timeout' seconds.
    """
    print("Waiting for OVMS server to be ready...")
    for i in range(timeout):
        try:
            resp = httpx.get(f"{BASE_URL}/v2/health/ready", timeout=2)
            if resp.status_code == 200:
                print(f"Server is ready! (took {i+1}s)")
                return
        except httpx.ConnectError:
            # Server not up yet - this is expected in early seconds
            pass
        print(f"  Polling... ({i+1}/{timeout}s)")
        time.sleep(1)
    raise TimeoutError("Server did not become ready in time.")


def chat_loop() -> None:
    """
    A minimal prompt loop that sends user input to the OpenAI-compatible
    endpoint and prints the response. Non-streaming for simplicity.
    """
    messages: list[dict] = []
    print("\nType your message. Press Ctrl+C to exit.\n")

    while True:
        try:
            user_input = input("You: ")
            if not user_input.strip():
                continue

            messages.append({"role": "user", "content": user_input})

            response = httpx.post(
                f"{BASE_URL}/v3/chat/completions",
                json={
                    "model": "your-model-name",  # replace with actual model
                    "messages": messages,
                    "stream": False,
                },
                timeout=30,
            )

            if response.status_code != 200:
                print(f"Error: Server returned {response.status_code}")
                print(response.text)
                messages.pop()  # Remove failed message
                continue

            reply = response.json()["choices"][0]["message"]["content"]
            print(f"Assistant: {reply}\n")
            messages.append({"role": "assistant", "content": reply})

        except KeyboardInterrupt:
            print("\nExiting chat.")
            break
        except Exception as e:
            print(f"Error: {e}")
            if messages:
                messages.pop()  # Remove failed message


if __name__ == "__main__":
    wait_for_ready()
    chat_loop()
