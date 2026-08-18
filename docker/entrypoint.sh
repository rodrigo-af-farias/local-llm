#!/bin/sh

set -e

echo "========================================"
echo " Local LLM - Starting Ollama"
echo "========================================"

ollama serve &
OLLAMA_PID=$!

echo "Waiting for Ollama..."

until ollama list >/dev/null 2>&1; do
    sleep 1
done

echo "Ollama is ready."

wait $OLLAMA_PID