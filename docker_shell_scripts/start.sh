#!/bin/bash

set -euo pipefail

printf "%s\n" "Starting Hydroxide..."

INFO_JSON_PATH="/data/info.json"

load_cached_auth() {
  if [ -s "$INFO_JSON_PATH" ] && grep -q '"hash":' "$INFO_JSON_PATH"; then
    HYDROXIDE_HASH=$(jq -r '.hash' "$INFO_JSON_PATH")
    PROTONMAIL_USER=$(jq -r '.user' "$INFO_JSON_PATH")
    return 0
  fi
  return 1
}

perform_auth() {
  if [ -z "${PROTONMAIL_USER:-}" ] || [ -z "${PROTONMAIL_PASS:-}" ] || [ -z "${PROTONMAIL_2FA:-}" ]; then
    printf "%s\n" "Missing ProtonMail credentials. Provide PROTONMAIL_USER, PROTONMAIL_PASS and PROTONMAIL_2FA."
    exit 1
  fi

  printf "%s\n" "Authentication required. Running expect script..."

  set +e
  expect_result=$(./expect.sh)
  expect_exit=$?
  set -e

  if [ $expect_exit -ne 0 ]; then
    printf "%s\n" "Hydroxide auth error"
    printf "%s\n" "$expect_result"
    exit $expect_exit
  fi

  hydroxide_hash_output=$(printf "%s" "$expect_result" | tail -n1)
  printf "%s\n" "$hydroxide_hash_output"
  IFS=":" read -ra hydroxide_hash_output_split <<< "$hydroxide_hash_output"
  HYDROXIDE_HASH="${hydroxide_hash_output_split[1]:1}"
  HYDROXIDE_HASH=$(printf "%s" "$HYDROXIDE_HASH" | tr -d '\r')

  printf "%s\n" "Logged in, user: $PROTONMAIL_USER, hash: $HYDROXIDE_HASH"
  printf "{\x22user\x22: \x22$PROTONMAIL_USER\x22, \x22hash\x22: \x22$HYDROXIDE_HASH\x22}" > "$INFO_JSON_PATH"
}

if [ "${HYDROXIDE_AUTH_ONLY:-0}" -eq 1 ]; then
  perform_auth
  printf "%s\n" "Authentication data stored. Exiting because HYDROXIDE_AUTH_ONLY=1."
  exit 0
fi

if load_cached_auth; then
  printf "%s\n" "Using existing authentication data."
else
  printf "%s\n" "No cached ProtonMail credentials found."
  printf "%s\n" "Enter the container shell (e.g. docker compose exec -it hydroxide /bin/sh)"
  printf "%s\n" "and run 'hydroxide-auth-cli' to authenticate. This container will wait for the credentials."

  until load_cached_auth; do
    sleep 3
  done

  printf "%s\n" "Credentials detected. Continuing startup."
fi

# MUST host on '0.0.0.0' for the ports to pass through to other containers
hydroxide -imap-host '0.0.0.0' imap &
hydroxide -smtp-host '0.0.0.0' smtp &
tail -f /dev/null
