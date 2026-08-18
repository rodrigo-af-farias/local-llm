# Local LLM

Docker images for running open-source LLMs locally using Ollama.

## Available models

| Model | Ollama model | Image |
|---|---|---|
| Qwen3 4B | `qwen3:4b` | `qwen3-4b` |

## Requirements

- Windows, Linux or macOS
- Docker Desktop / Docker Engine
- For NVIDIA GPU:
  - NVIDIA GPU
  - NVIDIA drivers
  - Docker configured with NVIDIA Container Toolkit

## Run with CPU

```bash
docker run --rm -p 11434:11434 ghcr.io/rodrigo-af-farias/qwen3-4b

## Run with NVIDIA GPU

```bash
docker run --rm --gpus all -p 11434:11434 ghcr.io/rodrigo-af-farias/qwen3-4b