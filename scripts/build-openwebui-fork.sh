#!/usr/bin/env sh
set -eu

export OPEN_WEBUI_FORK_PATH="${OPEN_WEBUI_FORK_PATH:-../zivo-openwebui}"
export OPEN_WEBUI_IMAGE="${OPEN_WEBUI_FORK_IMAGE:-zivo-openwebui:v0.8.12-zivo.1}"

if [ ! -f "$OPEN_WEBUI_FORK_PATH/Dockerfile" ]; then
  echo "Open WebUI fork Dockerfile not found at: $OPEN_WEBUI_FORK_PATH/Dockerfile" >&2
  echo "Run ./scripts/bootstrap-openwebui-fork.sh first, or set OPEN_WEBUI_FORK_PATH." >&2
  exit 1
fi

docker compose -f docker-compose.yml -f docker-compose.fork.yml build open-webui

cat <<EOF
Built Open WebUI fork image:
  image: $OPEN_WEBUI_IMAGE
  source: $OPEN_WEBUI_FORK_PATH

Run it with:
  OPEN_WEBUI_IMAGE=$OPEN_WEBUI_IMAGE docker compose -f docker-compose.yml -f docker-compose.fork.yml up -d open-webui
EOF
