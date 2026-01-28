#!/usr/bin/env bash

set -exuo pipefail

INTERVAL="${3:-5}"   # seconds between retries (default: 5)

echo "Importing state for ${NETWORK}..."

while true; do
  if [ -f "state.jsonl.zst" ]; then
    echo "state.jsonl.zst already downloaded"
    break
  fi
  if curl -fL --silent --show-error "https://storage.googleapis.com/conduit-public-dls/${NETWORK}-state.jsonl.zst" -o "state.jsonl.zst"; then
    echo "Download successful: state.jsonl.zst"
    break
  fi

  echo "Download failed, retrying in ${INTERVAL}s..."
  sleep "$INTERVAL"
done

if [ ! -f "state.jsonl" ]; then
  echo "decompressing state dump..."
  unzstd state.jsonl.zst
fi

while true; do
  if [ -f "header.hash" ]; then
    echo "header.hash already downloaded"
    break
  fi
  if curl -fL --silent --show-error "https://storage.googleapis.com/conduit-public-dls/${NETWORK}-header.hash" -o "header.hash"; then
    echo "Download successful: header.hash"
    break
  fi

  echo "Download failed, retrying in ${INTERVAL}s..."
  sleep "$INTERVAL"
done

while true; do
  if [ -f "header.rlp" ]; then
    echo "header.rlp already downloaded"
    break
  fi
  if curl -fL --silent --show-error "https://storage.googleapis.com/conduit-public-dls/${NETWORK}-header.rlp" -o "header.rlp"; then
    echo "Download successful: header.rlp"
    break
  fi

  echo "Download failed, retrying in ${INTERVAL}s..."
  sleep "$INTERVAL"
done

while true; do
  if [ -f "genesis.json" ]; then
    echo "genesis.json already downloaded"
    break
  fi
  if curl -fL --silent --show-error "https://storage.googleapis.com/conduit-public-dls/${NETWORK}-genesis.json" -o "genesis.json"; then
    echo "Download successful: genesis.json"
    break
  fi

  echo "Download failed, retrying in ${INTERVAL}s..."
  sleep "$INTERVAL"
done

if [ ! -f "${DATADIR}/db/static_files"]; then
  echo "doing initial state import..."
  op-reth init-state state.jsonl --datadir=$DATADIR --chain=genesis.json --header=header.rlp --header-hash=$(cat header.hash) --without-ovm
fi;

exec op-reth node --datadir=$DATADIR --chain=genesis.json "$@"
