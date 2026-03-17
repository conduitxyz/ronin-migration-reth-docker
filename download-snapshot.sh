#!/usr/bin/env bash

set -euo pipefail

SNAPSHOT_URL="https://storage.googleapis.com/conduit-networks-snapshots/saigon-testnet-cc58e966ql/latest.tar"
GENESIS_URL="https://api.conduit.xyz/file/v1/optimism/genesis/saigon-testnet-cc58e966ql"
DB_PATH="${DATADIR:-}/db/mdbx.dat"
GENESIS_PATH="${DATADIR:-}/genesis.json"

# if [[ -z "${DATADIR:-}" ]]; then
#   echo "DATADIR must be set"
#   exit 1
# fi

# mkdir -p "$DATADIR"

# if [[ ! -f "$DB_PATH" ]]; then
#   echo "Downloading snapshot into ${DATADIR}..."
#   curl -fL --retry 5 --retry-delay 5 "$SNAPSHOT_URL" | tar -xvf - -C "$DATADIR" --strip-components=1
# fi

if [[ ! -f "$GENESIS_PATH" ]]; then
  echo "Downloading genesis.json into ${DATADIR}..."
  curl -fL --retry 5 --retry-delay 5 "$GENESIS_URL" -o "$GENESIS_PATH"
fi

exec op-reth node --datadir="$DATADIR" --chain="$GENESIS_PATH" "$@"
