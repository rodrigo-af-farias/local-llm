# Local LLM

Ambiente para execução local de Large Language Models (LLMs) utilizando
[Ollama](https://ollama.com/) e Docker.

O projeto disponibiliza uma Web UI estilo ChatGPT para interação com os
modelos executados localmente.

## Características

- Execução completamente local
- Docker
- Ollama
- Web UI estilo ChatGPT
- Suporte a CPU
- Suporte a NVIDIA GPU
- Seleção explícita do modelo
- API HTTP do Ollama disponível localmente
- Cada modelo possui sua própria configuração
- Imagens Docker independentes por modelo

---

## Modelos disponíveis

| Modelo | Ollama | Imagem Docker |
|---|---|---|
| Qwen3 1.7B | `qwen3:1.7b` | `qwen3-1.7b` |
| Qwen3 4B | `qwen3:4b` | `qwen3-4b` |

O modelo **não é selecionado automaticamente**.

O usuário escolhe explicitamente qual modelo deseja executar através do
script `run-model.ps1`.

---

## Requisitos

- Windows, Linux ou macOS
- Docker Desktop ou Docker Engine
- PowerShell para utilização dos scripts fornecidos
- Para utilização de NVIDIA GPU:
  - GPU NVIDIA compatível
  - NVIDIA Driver
  - Docker configurado para utilização da GPU

---

# Execução

## Qwen3 1.7B

Execute:

```powershell
.\scripts\run-model.ps1 qwen3-1.7b