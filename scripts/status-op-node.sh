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

RPC_PORT="${OP_NODE_RPC_PORT:-7000}"
RPC_URL="http://localhost:${RPC_PORT}"

curl -sS -X POST "$RPC_URL" \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"optimism_syncStatus","params":[],"id":1}' | \
  sed 's/{/\n{/g'
