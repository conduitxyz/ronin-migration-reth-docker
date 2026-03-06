#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f ".env" ]]; then
  echo "Missing .env"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required. Install jq and retry."
  exit 1
fi

set -a
source .env
set +a

RPC_URL="${OP_NODE_RPC:-http://localhost:${OP_NODE_RPC_PORT:-7000}}"
L2_REMOTE_RPC="${L2_REMOTE_RPC:-${RETH_SEQUENCER_URL:-}}"

RESULT="$(curl -sS -m 8 -X POST "$RPC_URL" \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"optimism_syncStatus","params":[],"id":1}')" || {
  echo "Could not reach op-node RPC at $RPC_URL"
  exit 1
}

if ! echo "$RESULT" | jq -e '.result' >/dev/null 2>&1; then
  ERR_MSG="$(echo "$RESULT" | jq -r '.error.message // empty' 2>/dev/null || true)"
  if [[ -n "$ERR_MSG" ]]; then
    echo "op-node RPC error at $RPC_URL: $ERR_MSG"
  else
    echo "Unexpected op-node response from $RPC_URL"
  fi
  exit 1
fi

HEAD_L1="$(echo "$RESULT" | jq -r '.result.head_l1.number // 0')"
SAFE_L1="$(echo "$RESULT" | jq -r '.result.safe_l1.number // 0')"
FINALIZED_L1="$(echo "$RESULT" | jq -r '.result.finalized_l1.number // 0')"
UNSAFE_L2="$(echo "$RESULT" | jq -r '.result.unsafe_l2.number // 0')"
SAFE_L2="$(echo "$RESULT" | jq -r '.result.safe_l2.number // 0')"
FINALIZED_L2="$(echo "$RESULT" | jq -r '.result.finalized_l2.number // 0')"

LATEST_L2_REMOTE="N/A"
if [[ -n "$L2_REMOTE_RPC" ]]; then
  REMOTE_HEX="$(curl -sS -m 8 -X POST "$L2_REMOTE_RPC" \
    -H 'Content-Type: application/json' \
    -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | \
    jq -r '.result // empty' 2>/dev/null || true)"

  if [[ "$REMOTE_HEX" =~ ^0x[0-9a-fA-F]+$ ]]; then
    LATEST_L2_REMOTE="$(printf "%d" "$REMOTE_HEX" 2>/dev/null || echo "N/A")"
  fi
fi

echo "=== Sync Status - $(date) ==="
echo ""
echo "┌─────────────────────────────────┐"
echo "│           L1 Status             │"
echo "├─────────────────┬───────────────┤"
printf "│ %-15s │ %13s │\n" "Head" "$HEAD_L1"
printf "│ %-15s │ %13s │\n" "Safe" "$SAFE_L1"
printf "│ %-15s │ %13s │\n" "Finalized" "$FINALIZED_L1"
echo "└─────────────────┴───────────────┘"
echo ""
echo "┌─────────────────────────────────┐"
echo "│           L2 Status             │"
echo "├─────────────────┬───────────────┤"
printf "│ %-15s │ %13s │\n" "Unsafe" "$UNSAFE_L2"
printf "│ %-15s │ %13s │\n" "Safe" "$SAFE_L2"
printf "│ %-15s │ %13s │\n" "Finalized" "$FINALIZED_L2"
printf "│ %-15s │ %13s │\n" "Remote Latest" "$LATEST_L2_REMOTE"
echo "└─────────────────┴───────────────┘"
