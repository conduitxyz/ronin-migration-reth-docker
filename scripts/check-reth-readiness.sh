#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-.env}"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE"
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

HTTP_PORT="${RETH_HTTP_PORT:-8545}"

if ! docker ps --format '{{.Names}}' | grep -qx 'ronin-reth'; then
  echo "ronin-reth is not running. Run: make start-reth"
  exit 1
fi

RESPONSE="$(curl -sS -m 3 -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
  "http://localhost:${HTTP_PORT}")" || {
  echo "reth HTTP RPC not reachable on localhost:${HTTP_PORT}. Check: make logs-reth"
  exit 1
}

if command -v jq >/dev/null 2>&1; then
  if ! echo "$RESPONSE" | jq -e '.result' >/dev/null 2>&1; then
    echo "reth HTTP RPC responded without a valid result on localhost:${HTTP_PORT}"
    exit 1
  fi
elif ! echo "$RESPONSE" | grep -q '"result"'; then
  echo "reth HTTP RPC responded without a result on localhost:${HTTP_PORT}"
  exit 1
fi

echo "reth HTTP RPC is reachable on localhost:${HTTP_PORT}"
