#!/bin/bash

set -euo pipefail

printf "%s\n" "Hydroxide interactive auth."
printf "%s\n" "Stored credentials survive restarts via /data/info.json."

prompt_value() {
  local var_name=$1
  local prompt=$2
  local silent=${3:-0}

  if [ -n "${!var_name:-}" ]; then
    return
  fi

  if [ "$silent" -eq 1 ]; then
    read -srp "$prompt" value
    printf "\n"
  else
    read -rp "$prompt" value
  fi

  if [ -z "$value" ]; then
    printf "%s\n" "Value required."
    exit 1
  fi

  export "$var_name"="$value"
}

prompt_value "PROTONMAIL_USER" "ProtonMail username: "
prompt_value "PROTONMAIL_PASS" "ProtonMail password: " 1
prompt_value "PROTONMAIL_2FA" "ProtonMail 2FA TOTP code: "

export HYDROXIDE_AUTH_ONLY=1

exec /start.sh
