#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f ".env" ]]; then
  if [[ -f ".env.example" ]]; then
    cp .env.example .env
    echo "Created .env from .env.example"
    echo "Fill required L1/EigenDA env vars, then rerun make setup."
  else
    echo "Missing .env and .env.example"
  fi
  exit 1
fi

set -a
source .env
set +a

required=(
  NETWORK
  DATADIR
  RETH_SEQUENCER_URL
  OP_NODE_P2P_STATIC
  OP_NODE_L1_ETH_RPC
  OP_NODE_L1_BEACON
  EIGENDA_DIRECTORY
  EIGENDA_PROXY_EIGENDA_V2_CERT_VERIFIER_ROUTER_OR_IMMUTABLE_VERIFIER_ADDR
  EIGENDA_PROXY_EIGENDA_V2_DISPERSER_RPC
)
missing=()
for key in "${required[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    missing+=("$key")
  fi
done

if (( ${#missing[@]} > 0 )); then
  echo "Missing required env vars in .env: ${missing[*]}"
  exit 1
fi

if [[ "${EIGENDA_PROXY_STORAGE_BACKENDS_TO_ENABLE}" != "V2" ]]; then
  echo "EIGENDA_PROXY_STORAGE_BACKENDS_TO_ENABLE must be V2"
  exit 1
fi

if [[ "${EIGENDA_PROXY_STORAGE_DISPERSAL_BACKEND}" != "V2" ]]; then
  echo "EIGENDA_PROXY_STORAGE_DISPERSAL_BACKEND must be V2"
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

echo "Preflight OK (.env)"
