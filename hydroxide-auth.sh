#!/usr/bin/env bash

set -euo pipefail

COMPOSE_BIN="${COMPOSE_BIN:-docker compose}"
SERVICE_NAME="${SERVICE_NAME:-hydroxide}"

if ! command -v ${COMPOSE_BIN%% *} >/dev/null 2>&1; then
  printf "%s\n" "Cannot find docker compose binary (${COMPOSE_BIN}). Set COMPOSE_BIN to a valid command."
  exit 1
fi

read -rp "ProtonMail username: " PROTONMAIL_USER
read -srp "ProtonMail password: " PROTONMAIL_PASS
printf "\n"
read -rp "ProtonMail 2FA TOTP code: " PROTONMAIL_2FA

printf "%s\n" "Running hydroxide authentication inside the container..."

${COMPOSE_BIN} run --rm \
  -e HYDROXIDE_AUTH_ONLY=1 \
  -e PROTONMAIL_USER="$PROTONMAIL_USER" \
  -e PROTONMAIL_PASS="$PROTONMAIL_PASS" \
  -e PROTONMAIL_2FA="$PROTONMAIL_2FA" \
  "$SERVICE_NAME"
