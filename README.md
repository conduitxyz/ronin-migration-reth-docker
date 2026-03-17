# Ronin Migration Docker Images (op-reth, op-node)

Dockerfiles that can be used to run a reth node for the Ronin L1 -> L2 migration. This can be run as a typical reth node, with some extra parameters for the migration.

Note that you will need to run a consensus-layer client to power reth, typically `op-node`. Docs for running `op-node` are here: https://docs.optimism.io/node-operators/guides/configuration/consensus-clients. We also include an `op-node` that should be used.

We expect the testnet migration to take ~3 hours, and the mainnet migration to take ~7 hours.

## Ronin-specific configuration parameters

### Reth
For this Docker Compose setup, set `DATADIR` to the host directory you want Docker to mount into the reth container, for example `./datadir`. Inside the container, that directory is mounted at `/data`, and reth uses `/data` as its `--datadir` path.

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
cp .env.example .env
```

Set these in your env file:
- `DATADIR` as a host path, for example `./datadir` (mounted to `/data` inside the `execution` container)
- `NETWORK` (saigon or ronin)
- `OP_NODE_L1_ETH_RPC`
- `OP_NODE_L1_BEACON`
- `EIGENDA_PROXY_STORAGE_BACKENDS_TO_ENABLE=V2`
- `EIGENDA_PROXY_STORAGE_DISPERSAL_BACKEND=V2`

If you change `NETWORK`, rerun `make setup` to refresh those values and rebuild the images.

2. Run preflight and rebuild the images:

```bash
make setup
```

The reth container now uses the snapshot bootstrap path. On first start, it downloads the Saigon snapshot into `DATADIR`, strips the top-level `mnt/` directory from the archive, downloads `genesis.json` into `DATADIR`, and then starts `op-reth` directly. If `DATADIR/db/mdbx.dat` already exists, the snapshot download is skipped.

The final datadir layout should have snapshot files directly under `DATADIR`, for example:
- `DATADIR/db/...`
- `DATADIR/static_files/...`
- `DATADIR/blobstore/...`
- `DATADIR/invalid_block_hooks/...`
- `DATADIR/reth.toml`
- `DATADIR/genesis.json`
- `DATADIR/jwt.hex`

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
make stop-all
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


https://storage.googleapis.com/conduit-networks-snapshots/saigon-testnet-cc58e966ql/latest.tar

https://api.conduit.xyz/file/v1/optimism/genesis/saigon-testnet-cc58e966ql

https://storage.googleapis.com/conduit-public-dls/${NETWORK}-rollup.json


The snapshot archive currently extracts with a top-level `mnt/` directory, so the bootstrap script strips that layer and writes the contents directly into `DATADIR`.
