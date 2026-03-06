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

PROXY_PORT="${EIGENDA_PROXY_PORT:-3100}"

if ! docker ps --format '{{.Names}}' | grep -qx 'ronin-eigenda-proxy'; then
  echo "ronin-eigenda-proxy is not running. Run: make start-eigenda-proxy"
  exit 1
fi

if ! curl -fsS -m 5 "http://localhost:${PROXY_PORT}/health" >/dev/null; then
  echo "eigenda-proxy health check failed on localhost:${PROXY_PORT}. Check: make logs-eigenda-proxy"
  exit 1
fi

echo "eigenda-proxy is healthy on localhost:${PROXY_PORT}"
