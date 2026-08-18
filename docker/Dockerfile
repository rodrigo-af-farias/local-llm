FROM ollama/ollama:latest

ARG MODEL

ENV OLLAMA_HOST=0.0.0.0:11434

EXPOSE 11434

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN ollama serve & \
    OLLAMA_PID=$! && \
    sleep 5 && \
    ollama pull ${MODEL} && \
    kill $OLLAMA_PID

ENTRYPOINT ["/entrypoint.sh"]