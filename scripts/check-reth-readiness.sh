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

AUTH_PORT="${RETH_AUTHRPC_PORT:-9551}"

if ! docker ps --format '{{.Names}}' | grep -qx 'ronin-reth'; then
  echo "ronin-reth is not running. Run: make start-reth"
  exit 1
fi

if ! curl -sS -m 3 -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
  "http://localhost:${AUTH_PORT}" >/dev/null; then
  echo "reth authrpc not ready on localhost:${AUTH_PORT}. Check: make logs-reth"
  exit 1
fi

echo "reth authrpc is reachable on localhost:${AUTH_PORT}"
