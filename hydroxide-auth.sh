#!/usr/bin/env bash

set -euo pipefail

COMPOSE_BIN="${COMPOSE_BIN:-docker compose}"
SERVICE_NAME="${SERVICE_NAME:-hydroxide}"

if ! command -v ${COMPOSE_BIN%% *} >/dev/null 2>&1; then
  printf "%s\n" "Cannot find docker compose binary (${COMPOSE_BIN}). Set COMPOSE_BIN to a valid command."
  exit 1
fi

if ! ${COMPOSE_BIN} ps --services --filter status=running | grep -qx "$SERVICE_NAME"; then
  printf "%s\n" "Service '$SERVICE_NAME' is not running. Start it first with 'docker compose up -d %s'." "$SERVICE_NAME"
  exit 1
fi

printf "%s\n" "Running interactive auth inside the existing container..."

${COMPOSE_BIN} exec -it "$SERVICE_NAME" /usr/local/bin/hydroxide-auth-cli
