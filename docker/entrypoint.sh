#!/bin/sh

set -e

echo "========================================"
echo " local llm - iniciando"
echo "========================================"

if [ -z "$MODEL" ]; then
    echo "ERRO: A variável de ambiente MODEL não foi definida."
    exit 1
fi

echo "Modelo:       $MODEL"
echo "Ollama:      http://127.0.0.1:11434"
echo "Web UI:      http://0.0.0.0:3000"
echo "========================================"
echo ""

cleanup() {
    echo ""
    echo "Parando local llm..."

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

echo "Iniciando ollama..."

ollama serve &
OLLAMA_PID=$!

echo "Aguardando ollama..."

until ollama list >/dev/null 2>&1; do
    if ! kill -0 "$OLLAMA_PID" 2>/dev/null; then
        echo "ERRO: Ollama parou inesperadamente."
        exit 1
    fi

    sleep 1
done

echo "Ollama está pronto."

echo ""
echo "Iniciando web ui..."

nginx -g "daemon off;" &
NGINX_PID=$!

echo "Web ui está pronto."
echo ""
echo "========================================"
echo " local llm está rodando"
echo "========================================"
echo "Modelo:       $MODEL"
echo "Web UI:      http://localhost:3000"
echo "API:         http://localhost:11434"
echo "========================================"
echo ""

while true; do
    if ! kill -0 "$OLLAMA_PID" 2>/dev/null; then
        echo "ERRO: Ollama parou inesperadamente."
        exit 1
    fi

    if ! kill -0 "$NGINX_PID" 2>/dev/null; then
        echo "ERRO: Nginx parou inesperadamente."
        exit 1
    fi

    sleep 2
done