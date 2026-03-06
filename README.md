# Ronin Migration Docker Images (op-reth, op-node)

Dockerfiles that can be used to run a reth node for the Ronin L1 -> L2 migration. This can be run as a typical reth node, with some extra parameters for the migration.

Note that you will need to run a consensus-layer client to power reth, typically `op-node`. Docs for running `op-node` are here: https://docs.optimism.io/node-operators/guides/configuration/consensus-clients. We also include an `op-node` that should be used.

We expect the testnet migration to take ~3 hours, and the mainnet migration to take ~7 hours.

## Ronin-specific configuration parameters

### Reth
Set the environment variable `DATADIR` to the same `--datadir` parameter you would pass into reth. This sets the datadir path for the initial state import.

You will also need to set the `NETWORK=[saigon|ronin]` environment variable, depending on which network you are running the image for. For Saigon select `saigon`, for ronin mainnet select `ronin`.

The rollup sequencer endpoint for testnet will be: https://rpc-saigon-testnet-cc58e966ql.t.conduit.xyz

For Mainnet it will be: https://rpc-ronin-mainnet-bfz9fadqzl.t.conduit.xyz

Other arguments will need to be set as well, below is an example you might set in a k8s yaml file:
```
env:
- name: DATADIR
  value: /path/to/datadir
- name: NETWORK
  value: saigon
args:
- --rollup.sequencer https://rpc-saigon-testnet-cc58e966ql.t.conduit.xyz --http --ws --authrpc.port 9551 --authrpc.jwtsecret /path/to/jwt.hex
```

### Op-node
The rollup.json file with automatically be downloaded, and environmental variable set, so no need to set the `--rollup.config` flag.

In addition the standard parameters, you will need to set the `OP_NODE_P2P_STATIC` variable.

For Saigon: `OP_NODE_P2P_STATIC=/ip4/34.187.134.72/tcp/9222/p2p/16Uiu2HAmFyGhL6G7CRgc77zmEeWAdBJA2vFsY9LSYzJQfnCrpWUW`

For Ronin: `OP_NODE_P2P_STATIC=/ip4/34.11.218.92/tcp/9222/p2p/16Uiu2HAm2wpj12oJjJJS3EwkpCMMJBw5FvbKivQLLC9TzMmh456G`

You will also need to set the `NETWORK=[saigon|ronin]` environment variable, depending on which network you are running the image for. For Saigon select `saigon`, for ronin mainnet select `ronin`.

Other arguments will need to be set as well, below is an example you might set in a k8s yaml file:
```
env:
- name: OP_NODE_P2P_STATIC
  value: /ip4/34.187.134.72/tcp/9222/p2p/16Uiu2HAmFyGhL6G7CRgc77zmEeWAdBJA2vFsY9LSYzJQfnCrpWUW
- name: NETWORK
  value: saigon
args:
- --l1=<your-ethereum-L1-rpc> --l2=http://localhost:9551 --l2.jwt-secret=/path/to/jwt.hex --rpc.addr=0.0.0.0 --rpc.port=7000 --l1.beacon=<your-beacon-node-http-endpoint>
```
## Quick start

1. Copy env template and fill required L1 endpoints:

Use `.env.example` directly, or copy it to a local file:

```bash
cp .env.example .env.local
```

Set these in your env file:

- `OP_NODE_L1_ETH_RPC`
- `OP_NODE_L1_BEACON`
- `EIGENDA_DIRECTORY`
- `EIGENDA_PROXY_EIGENDA_V2_CERT_VERIFIER_ROUTER_OR_IMMUTABLE_VERIFIER_ADDR`
- `EIGENDA_PROXY_EIGENDA_V2_DISPERSER_RPC`
- `EIGENDA_PROXY_STORAGE_BACKENDS_TO_ENABLE=V2`
- `EIGENDA_PROXY_STORAGE_DISPERSAL_BACKEND=V2`

2. Run preflight:

```bash
make setup
# or: make setup ENV_FILE=.env.local
```

3. Start execution (reth) first:

```bash
make start-reth
```

4. Start op-node (this auto-starts EigenDA proxy first):

```bash
make start-op-node
```

If reth or eigenda-proxy is not ready, `start-op-node` exits with a clear message.
You can still run `make start-eigenda-proxy` manually for debugging.

## Useful commands

```bash
make logs-reth
make logs-eigenda-proxy
make logs-op-node
make status
make stop-op-node
make stop-eigenda-proxy
make stop-reth
```
## Resource specifications
Testnet:

CPU: 2

Memory: 40Gi

Disk: 100Gi


Mainnet:

CPU: 2

Memory: 120Gi

Disk: 800Gi

## Troubleshooting

If you run into issues, try deleting the persistent data in your `--datadir` directory and restart the reth container image.

## Rolling your own
If you'd like to roll your own images, the appropriate files will be available under:


https://storage.googleapis.com/conduit-public-dls/${NETWORK}-state.jsonl.zst

https://storage.googleapis.com/conduit-public-dls/${NETWORK}-header.hash

https://storage.googleapis.com/conduit-public-dls/${NETWORK}-header.rlp

https://storage.googleapis.com/conduit-public-dls/${NETWORK}-genesis.json

https://storage.googleapis.com/conduit-public-dls/${NETWORK}-rollup.json


Where you can replace ${NETWORK} with [saigon|ronin], depending on which network you are syncing.
