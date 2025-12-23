#!/bin/bash

set -euo pipefail

printf "%s\n" "Starting Hydroxide..."

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
AUTH_JSON_PATH="$CONFIG_HOME/hydroxide/auth.json"

LOWERCASE_DEBUG_FLAG=""
if [ -n "${HYDROXIDE_DEBUG:-}" ]; then
  LOWERCASE_DEBUG_FLAG="$(printf '%s' "$HYDROXIDE_DEBUG" | tr '[:upper:]' '[:lower:]')"
fi

ENABLE_DEBUG=false
case "$LOWERCASE_DEBUG_FLAG" in
  1|true|yes|on|debug)
    ENABLE_DEBUG=true
    printf "%s\n" "Hydroxide debug logging enabled (HYDROXIDE_DEBUG=$HYDROXIDE_DEBUG)."
    ;;
esac

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
common_flags=()
if [ "$ENABLE_DEBUG" = true ]; then
  common_flags+=("-debug")
fi

hydroxide "${common_flags[@]}" -imap-host '0.0.0.0' imap &
hydroxide "${common_flags[@]}" -smtp-host '0.0.0.0' smtp &
tail -f /dev/null
