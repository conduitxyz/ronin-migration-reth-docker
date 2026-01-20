#!/usr/bin/env bash

set -exuo pipefail

INTERVAL="${3:-5}"   # seconds between retries (default: 5)

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

exec OP_NODE_ROLLUP_CONFIG=rollup.json op-node "$@"