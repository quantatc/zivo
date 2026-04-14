#!/usr/bin/env bash

set -euo pipefail

OLLAMA_CONTAINER="zivo-ollama"
CHROMA_CONTAINER="zivo-chroma"
MODEL_NAME="nomic-embed-text"

wait_for_ollama() {
  echo "Waiting for ${OLLAMA_CONTAINER} to become healthy..."

  while true; do
    status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}missing{{end}}' "${OLLAMA_CONTAINER}" 2>/dev/null || true)"

    case "${status}" in
      healthy)
        echo "${OLLAMA_CONTAINER} is healthy."
        return 0
        ;;
      starting)
        sleep 5
        ;;
      unhealthy)
        echo "${OLLAMA_CONTAINER} became unhealthy. Check docker logs ${OLLAMA_CONTAINER}."
        exit 1
        ;;
      *)
        echo "Current status: ${status:-unknown}. Waiting..."
        sleep 5
        ;;
    esac
  done
}

pull_embedding_model() {
  echo "Pulling ${MODEL_NAME} into ${OLLAMA_CONTAINER}..."
  docker exec "${OLLAMA_CONTAINER}" ollama pull "${MODEL_NAME}"
  echo "Ollama model ${MODEL_NAME} is ready."
}

check_chroma() {
  echo "Checking Chroma heartbeat from inside ${CHROMA_CONTAINER}..."

  if docker exec "${CHROMA_CONTAINER}" python -c "import os, urllib.request; req = urllib.request.Request('http://127.0.0.1:8000/api/v1/heartbeat', headers={'Authorization': f'Bearer {os.environ[\"CHROMA_SERVER_AUTHN_CREDENTIALS\"]}'}); print(urllib.request.urlopen(req, timeout=5).read().decode())"; then
    echo "Chroma is reachable."
  else
    echo "Chroma heartbeat check failed."
  fi
}

print_next_steps() {
  cat <<'EOF'

Next steps:
1. Run `docker compose ps` and confirm all containers are healthy or running.
2. Reload Caddy after placing the updated Caddyfile on the host.
3. Open `https://zivo.tafarax.com`, `https://zivo.tafarax.com/n8n/`, and `https://zivo.tafarax.com/reports/`.
4. In Open WebUI, configure your RAG workflow to use Chroma and `nomic-embed-text` through Ollama.

EOF
}

wait_for_ollama
pull_embedding_model
check_chroma
print_next_steps
