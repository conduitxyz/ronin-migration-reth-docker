#!/usr/bin/env bash
set -euo pipefail

load_env() {
  set -a
  source .env
  set +a
}

upsert_env_var() {
  local key="$1"
  local value="$2"

  if grep -q "^${key}=" .env; then
    sed -i.bak "s|^${key}=.*|${key}=${value}|" .env
  else
    printf '%s=%s\n' "$key" "$value" >> .env
  fi
}

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

load_env

case "${NETWORK:-}" in
  saigon)
    resolved_eigenda_directory="0x9620dC4B3564198554e4D2b06dEFB7A369D90257"
    resolved_verifier_addr="0x17ec4112c4BbD540E2c1fE0A49D264a280176F0D"
    resolved_disperser_rpc="disperser-testnet-sepolia.eigenda.xyz:443"
    ;;
  ronin)
    resolved_eigenda_directory="0x64AB2e9A86FA2E183CB6f01B2D4050c1c2dFAad4"
    resolved_verifier_addr="0x1be7258230250Bc6a4548F8D59d576a87D216C12"
    resolved_disperser_rpc="disperser.eigenda.xyz:443"
    ;;
  "")
    echo "NETWORK is required in .env before running setup"
    exit 1
    ;;
  *)
    echo "Unsupported NETWORK '${NETWORK}'. Expected one of: saigon, ronin"
    exit 1
    ;;
esac

upsert_env_var "EIGENDA_DIRECTORY" "$resolved_eigenda_directory"
upsert_env_var "EIGENDA_PROXY_EIGENDA_V2_CERT_VERIFIER_ROUTER_OR_IMMUTABLE_VERIFIER_ADDR" "$resolved_verifier_addr"
upsert_env_var "EIGENDA_PROXY_EIGENDA_V2_DISPERSER_RPC" "$resolved_disperser_rpc"
rm -f .env.bak
load_env

required=(
  NETWORK
  DATADIR
  RETH_SEQUENCER_URL
  OP_NODE_P2P_STATIC
  OP_NODE_L1_ETH_RPC
  OP_NODE_L1_BEACON
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

echo "Configured EigenDA proxy defaults for ${NETWORK}"
echo "Preflight OK (.env)"
