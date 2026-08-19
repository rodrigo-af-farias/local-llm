FROM ollama/ollama:latest

ARG MODEL

ENV MODEL=${MODEL}
ENV OLLAMA_HOST=0.0.0.0:11434

EXPOSE 3000
EXPOSE 11434

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/*

COPY docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

COPY web/index.html /usr/share/nginx/html/index.html
COPY web/app.js /usr/share/nginx/html/app.js
COPY web/style.css /usr/share/nginx/html/style.css
COPY web/nginx.conf /etc/nginx/conf.d/default.conf

RUN printf '{\n  "model": "%s"\n}\n' "${MODEL}" \
    > /usr/share/nginx/html/model-config.json

RUN ollama serve & \
    OLLAMA_PID=$! && \
    sleep 5 && \
    ollama pull ${MODEL} && \
    kill $OLLAMA_PID

ENTRYPOINT ["/entrypoint.sh"]