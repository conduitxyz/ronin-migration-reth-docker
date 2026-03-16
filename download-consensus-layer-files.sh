#!/usr/bin/env bash

set -exuo pipefail

INTERVAL=5   # seconds between retries (default: 5)

echo "Importing state for ${NETWORK}..."

while true; do
  if [ -f "rollup.json" ]; then
    echo "rollup.json already downloaded"
    break
  fi
  if curl -fL --silent --show-error "https://storage.googleapis.com/conduit-public-dls/${NETWORK}-rollup.json" -o "rollup.json"; then
    echo "Download successful: rollup.json"
    break
  fi

  echo "Download failed, retrying in ${INTERVAL}s..."
  sleep "$INTERVAL"
done

echo "Ensuring EigenDA alt_da config is present in rollup.json..."
jq '.alt_da = {
  "da_commitment_type": "GenericCommitment",
  "da_challenge_contract_address": "0x0000000000000000000000000000000000000000",
  "da_challenge_window": 1,
  "da_resolve_window": 1
}' rollup.json > rollup.json.tmp
mv rollup.json.tmp rollup.json

OP_NODE_ROLLUP_CONFIG=rollup.json op-node "$@"
