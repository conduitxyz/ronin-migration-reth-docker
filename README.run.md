# Docker Compose Workflow (Additive)

This file adds a `~/Developer/node`-style workflow without modifying existing repo scripts.

## Quick start

1. Copy env template and fill required L1 endpoints:

Use `.env.example` directly, or copy it to a local file:

```bash
cp .env.example .env.local
```

Set these in your env file:

- `OP_NODE_L1_ETH_RPC`
- `OP_NODE_L1_BEACON`

2. Run preflight:

```bash
make setup
# or: make setup ENV_FILE=.env.local
```

3. Start execution (reth) first:

```bash
make start-reth
```

4. Wait for reth readiness, then start op-node:

```bash
make start-op-node
```

If reth is not ready, `start-op-node` exits with a clear message.

## Useful commands

```bash
make logs-reth
make logs-op-node
make status-op-node
make stop-op-node
make stop-reth
```

## Notes
- op-node uses internal service routing to execution at `http://execution:9551`.
