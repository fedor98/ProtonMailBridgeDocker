#!/bin/bash

set -euo pipefail

printf "%s\n" "Starting Hydroxide..."

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
AUTH_JSON_PATH="$CONFIG_HOME/hydroxide/auth.json"

wait_for_auth() {
  if [ -s "$AUTH_JSON_PATH" ]; then
    return 0
  fi
  return 1
}

if wait_for_auth; then
  printf "%s\n" "Found cached ProtonMail credentials at $AUTH_JSON_PATH."
else
  printf "%s\n" "No cached ProtonMail credentials found."
  printf "%s\n" "Enter the container shell (e.g. docker compose exec -it hydroxide /bin/sh)"
  printf "%s\n" "and run 'hydroxide auth <username>' to authenticate. This container will wait for the credentials."

  until wait_for_auth; do
    sleep 3
  done

  printf "%s\n" "Credentials detected. Continuing startup."
fi

# MUST host on '0.0.0.0' for the ports to pass through to other containers
hydroxide -imap-host '0.0.0.0' imap &
hydroxide -smtp-host '0.0.0.0' smtp &
tail -f /dev/null
