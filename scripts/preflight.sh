#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  if [[ -f ".env.example" ]]; then
    cp .env.example "$ENV_FILE"
    echo "Created $ENV_FILE from .env.example"
    echo "Fill OP_NODE_L1_ETH_RPC and OP_NODE_L1_BEACON, then rerun make setup."
  else
    echo "Missing $ENV_FILE and .env.example"
  fi
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

required=(NETWORK DATADIR RETH_SEQUENCER_URL OP_NODE_P2P_STATIC OP_NODE_L1_ETH_RPC OP_NODE_L1_BEACON)
missing=()
for key in "${required[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    missing+=("$key")
  fi
done

if (( ${#missing[@]} > 0 )); then
  echo "Missing required env vars in $ENV_FILE: ${missing[*]}"
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose is required"
  exit 1
fi

mkdir -p "$DATADIR"

JWT_PATH="$DATADIR/jwt.hex"
if [[ ! -f "$JWT_PATH" ]]; then
  openssl rand -hex 32 > "$JWT_PATH"
  echo "Created $JWT_PATH"
fi

echo "Preflight OK ($ENV_FILE)"
