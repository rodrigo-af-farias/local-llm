#!/bin/sh

set -e

echo "========================================"
echo " Local LLM - Starting"
echo "========================================"

if [ -z "$MODEL" ]; then
    echo "ERROR: MODEL environment variable is not set."
    exit 1
fi

echo "Model:       $MODEL"
echo "Ollama:      http://127.0.0.1:11434"
echo "Web UI:      http://0.0.0.0:3000"
echo "========================================"
echo ""

cleanup() {
    echo ""
    echo "Stopping Local LLM..."

    if [ -n "$NGINX_PID" ] && kill -0 "$NGINX_PID" 2>/dev/null; then
        kill "$NGINX_PID" 2>/dev/null || true
    fi

    if [ -n "$OLLAMA_PID" ] && kill -0 "$OLLAMA_PID" 2>/dev/null; then
        kill "$OLLAMA_PID" 2>/dev/null || true
    fi

    wait "$NGINX_PID" 2>/dev/null || true
    wait "$OLLAMA_PID" 2>/dev/null || true
}

trap cleanup INT TERM EXIT

echo "Starting Ollama..."

ollama serve &
OLLAMA_PID=$!

echo "Waiting for Ollama..."

until ollama list >/dev/null 2>&1; do
    if ! kill -0 "$OLLAMA_PID" 2>/dev/null; then
        echo "ERROR: Ollama stopped unexpectedly."
        exit 1
    fi

    sleep 1
done

echo "Ollama is ready."

echo ""
echo "Starting Web UI..."

nginx -g "daemon off;" &
NGINX_PID=$!

echo "Web UI is ready."
echo ""
echo "========================================"
echo " Local LLM is running"
echo "========================================"
echo "Model:       $MODEL"
echo "Web UI:      http://localhost:3000"
echo "API:         http://localhost:11434"
echo "========================================"
echo ""

while true; do
    if ! kill -0 "$OLLAMA_PID" 2>/dev/null; then
        echo "ERROR: Ollama stopped unexpectedly."
        exit 1
    fi

    if ! kill -0 "$NGINX_PID" 2>/dev/null; then
        echo "ERROR: Nginx stopped unexpectedly."
        exit 1
    fi

    sleep 2
done