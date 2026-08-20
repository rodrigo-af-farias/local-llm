# Local LLM

Execute modelos de linguagem localmente através de Docker, com Ollama e uma Web UI incluídos na mesma imagem.

O usuário não precisa instalar Python, Ollama, Node.js ou configurar uma aplicação web separadamente.

## Modelos disponíveis

| Modelo     | Imagem                                        |
| ---------- | --------------------------------------------- |
| Qwen3 1.7B | `ghcr.io/rodrigo-af-farias/qwen3-1.7b:latest` |
| Qwen3 4B   | `ghcr.io/rodrigo-af-farias/qwen3-4b:latest`   |

## Requisitos

* Docker Desktop
* Windows, Linux ou macOS compatível com Docker
* Para execução via CPU: nenhum hardware adicional
* Para execução via NVIDIA GPU:

  * GPU NVIDIA compatível
  * drivers NVIDIA instalados
  * suporte a GPU do Docker configurado

## Execução via CPU

Escolha um modelo e faça o pull da imagem.

### Qwen3 1.7B

```bash
docker pull ghcr.io/rodrigo-af-farias/qwen3-1.7b:latest
```

Execute:

```bash
docker run --rm -p 3000:3000 ghcr.io/rodrigo-af-farias/qwen3-1.7b:latest
```

### Qwen3 4B

```bash
docker pull ghcr.io/rodrigo-af-farias/qwen3-4b:latest
```

Execute:

```bash
docker run --rm -p 3000:3000 ghcr.io/rodrigo-af-farias/qwen3-4b:latest
```

Depois abra:

**http://localhost:3000**

A Web UI exibirá o modelo que está sendo executado.

## Execução via NVIDIA GPU

A mesma imagem pode ser utilizada em uma máquina com GPU NVIDIA.

Adicione `--gpus all` ao comando `docker run`.

### Qwen3 1.7B

```bash
docker run --rm --gpus all -p 3000:3000 ghcr.io/rodrigo-af-farias/qwen3-1.7b:latest
```

### Qwen3 4B

```bash
docker run --rm --gpus all -p 3000:3000 ghcr.io/rodrigo-af-farias/qwen3-4b:latest
```

O Ollama detectará os recursos de hardware disponíveis no container.

Em uma máquina sem NVIDIA, simplesmente não utilize `--gpus all`.

## Acessando a Web UI

Com o container em execução:

**http://localhost:3000**

A aplicação fornece uma interface de chat para conversar diretamente com o modelo local.

A comunicação ocorre localmente entre a Web UI, o Ollama e o modelo.

## Como parar o modelo

Se o container foi iniciado com:

```bash
docker run --rm ...
```

pressione:

```text
Ctrl + C
```

O container será encerrado e removido automaticamente.

## Porta 3000 em uso

Se a porta `3000` estiver sendo utilizada por outro processo ou container, verifique os containers ativos:

```bash
docker ps
```

Pare o container que estiver utilizando a porta:

```bash
docker stop <CONTAINER_ID>
```

Depois execute novamente o modelo.

Também é possível utilizar outra porta no host. Por exemplo:

```bash
docker run --rm -p 8080:3000 ghcr.io/rodrigo-af-farias/qwen3-4b:latest
```

Nesse caso, acesse:

**http://localhost:8080**

A porta `3000` dentro do container não precisa ser alterada.

## Arquitetura

Cada modelo é distribuído como uma única imagem Docker.

```text
┌──────────────────────────────────────────┐
│          Docker Image                    │
│                                          │
│  ┌──────────────┐                        │
│  │   Ollama     │                        │
│  │   :11434     │                        │
│  └──────┬───────┘                        │
│         │                                │
│         ▼                                │
│     Qwen3 Model                          │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │            Nginx :3000             │  │
│  │                                    │  │
│  │              Web UI                │  │
│  └────────────────────────────────────┘  │
│                                          │
└──────────────────┬───────────────────────┘
                   │
                   ▼
            localhost:3000
```

Não é necessário executar Docker Compose nem iniciar containers separados para Ollama e Web UI.

## Estrutura do projeto

```text
local-llm/
│
├── .github/
│   ├── CODEOWNERS
│   └── workflows/
│       ├── copilot-review.yml
│       └── docker.yml
│
├── docker/
│   ├── Dockerfile
│   └── entrypoint.sh
│
├── models/
│   ├── qwen3-1.7b/
│   │   └── config.env
│   └── qwen3-4b/
│       └── config.env
│
├── scripts/
│   └── build-model.ps1
│
└── web/
    ├── app.js
    ├── index.html
    ├── nginx.conf
    └── style.css
```

## Como as imagens são construídas

Cada modelo possui um arquivo `config.env`:

```env
MODEL=qwen3:4b
IMAGE_NAME=qwen3-4b
```

ou:

```env
MODEL=qwen3:1.7b
IMAGE_NAME=qwen3-1.7b
```

Durante o build, o modelo é passado como argumento para o Dockerfile:

```dockerfile
ARG MODEL
```

A imagem executa o Ollama durante o processo de build e baixa o modelo:

```dockerfile
RUN ollama serve & \
    OLLAMA_PID=$! && \
    sleep 5 && \
    ollama pull ${MODEL} && \
    kill $OLLAMA_PID
```

Consequentemente, o modelo já está incorporado à imagem publicada no GHCR.

## Build local

Para construir uma imagem localmente:

```powershell
.\scripts\build-model.ps1 qwen3-4b
```

Ou:

```powershell
.\scripts\build-model.ps1 qwen3-1.7b
```

Depois:

```powershell
docker run --rm -p 3000:3000 qwen3-4b
```

ou:

```powershell
docker run --rm -p 3000:3000 qwen3-1.7b
```

## Publicação

As imagens são publicadas automaticamente no GitHub Container Registry (GHCR) através da GitHub Actions.

O workflow está em:

```text
.github/workflows/docker.yml
```

A pipeline constrói os modelos definidos na matriz de modelos e publica as imagens correspondentes:

```text
ghcr.io/rodrigo-af-farias/qwen3-1.7b:latest
ghcr.io/rodrigo-af-farias/qwen3-4b:latest
```

O fluxo de publicação é:

```text
Git push
   │
   ▼
GitHub Actions
   │
   ├── Build Qwen3 1.7B
   │
   └── Build Qwen3 4B
          │
          ▼
         GHCR
```

## Adicionando um novo modelo

Para adicionar outro modelo:

1. Crie uma nova pasta em `models/`.

Exemplo:

```text
models/qwen3-8b/
```

2. Crie o arquivo `config.env`:

```env
MODEL=qwen3:8b
IMAGE_NAME=qwen3-8b
```

3. Adicione o modelo à matriz do workflow:

```yaml
strategy:
  matrix:
    model:
      - qwen3-1.7b
      - qwen3-4b
      - qwen3-8b
```

A GitHub Action construirá e publicará automaticamente:

```text
ghcr.io/rodrigo-af-farias/qwen3-8b:latest
```

A Web UI não precisa ser duplicada para cada modelo.

## Privacidade

A inferência é executada localmente pelo Ollama dentro do container.

A aplicação Web UI se comunica com o Ollama localmente através da rede interna do container.

Não é necessário enviar as mensagens para um serviço externo de inferência.
