# Ronin Migration Docker Images (op-reth, op-node, eigenda-proxy)

Dockerfiles that can be used to run a reth node for the Ronin L1 -> L2 migration. This setup runs reth alongside `op-node` and `eigenda-proxy`, with `make` selecting either snapshot bootstrap or migration import bootstrap.

Note that you will need to run a consensus-layer client to power reth, typically `op-node`. Docs for running `op-node` are here: https://docs.optimism.io/node-operators/guides/configuration/consensus-clients. We also include an `op-node` that should be used.

## Component Versions

| Component | Version |
| --- | --- |
| reth (execution) | `ghcr.io/conduitxyz/conduit-op-reth:v1.0.0-rc.1` |
| op-node | `us-docker.pkg.dev/oplabs-tools-artifacts/images/op-node:v1.16.5` |
| eigenda-proxy | `ghcr.io/layr-labs/eigenda-proxy:2.7.0` |

The execution client uses Conduit's custom `conduit-op-reth` build rather than stock upstream `op-reth`.

## Ronin-specific configuration parameters

### Reth
For this Docker Compose setup, set `DATADIR` to the host directory you want Docker to mount into the reth container, for example `./datadir`. Inside the container, that directory is mounted at `/data`, and reth uses `/data` as its `--datadir` path.

Bootstrap mode is controlled by `SNAPSHOT`:
- `SNAPSHOT=true` uses the snapshot path via `download-snapshot.sh`
- `SNAPSHOT=false` uses the migration import path via `download-migration-files.sh`

For snapshot mode, the final datadir layout should contain snapshot files directly under `${DATADIR}`.

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

`op-node` depends on `eigenda-proxy` for the configured alt-DA path in this setup. `make start-op-node` auto-starts `eigenda-proxy` first, and you can still run `make start-eigenda-proxy` manually for debugging.

In addition the standard parameters, you will need to set the `OP_NODE_P2P_STATIC` variable.

For Saigon: `OP_NODE_P2P_STATIC=/ip4/34.187.134.72/tcp/9222/p2p/16Uiu2HAmFyGhL6G7CRgc77zmEeWAdBJA2vFsY9LSYzJQfnCrpWUW`

For Ronin: `OP_NODE_P2P_STATIC=/ip4/34.169.70.196/tcp/9222/p2p/16Uiu2HAkxJUuUQFe6eLwhT8pHYRFYTch1MoeuWDoEFKbdAZANbMk`

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
- `SNAPSHOT=true|false` to select bootstrap mode
- `OP_NODE_L1_ETH_RPC`
- `OP_NODE_L1_BEACON`
- `EIGENDA_PROXY_STORAGE_BACKENDS_TO_ENABLE=V2`
- `EIGENDA_PROXY_STORAGE_DISPERSAL_BACKEND=V2`
- `EIGENDA_PROXY_EIGENDA_V2_NETWORK=sepolia_testnet # or mainnet`
- `UPDATE_BEDROCK_BLOCK=true` (optional, default `false`) — overrides `bedrockBlock` in the downloaded `genesis.json` to the network-specific migration block: `45528550` for saigon, `55577500` for ronin. When enabled, set `RETH_HISTORICAL_RPC` to an RPC endpoint that can serve pre-bedrock historical data.
- `RETH_HISTORICAL_RPC` — RPC URL for pre-bedrock historical block data, used with `--rollup.historicalrpc`

#### Populated by `make setup` based on NETWORK automatically
- `EIGENDA_PROXY_EIGENDA_V2_CERT_VERIFIER_ROUTER_OR_IMMUTABLE_VERIFIER_ADDR`
- `EIGENDA_PROXY_EIGENDA_V2_DISPERSER_RPC`

If you change `NETWORK`, rerun `make setup` to refresh those values and rebuild the images.

2. Choose the bootstrap path.

Snapshot mode:

- Use `SNAPSHOT=true`
- `make` uses `docker-compose.yml`
- The execution container runs `download-snapshot.sh`
- Prepare `DATADIR` with snapshot contents if you are loading them manually

Import mode:

- Use `SNAPSHOT=false`
- `make` uses `docker-compose-import.yml`
- The execution container runs `download-migration-files.sh`
- Use this path when no snapshot is available and reth must import from migration files

3. If you are using snapshot mode, prepare `DATADIR` with the snapshot contents.

If you are preparing the snapshot manually instead of relying on the container entrypoint, use the command for your network:

Saigon:

```bash
mkdir -p ./datadir && gsutil cp gs://conduit-networks-snapshots/saigon-testnet-cc58e966ql/latest.tar - | tar -xvf - -C ./datadir --strip-components=1
```

Ronin:

```bash
mkdir -p ./datadir && gsutil cp gs://conduit-networks-snapshots/ronin-mainnet-bfz9fadqzl/latest.tar - | tar -xvf - -C ./datadir --strip-components=1
```


4. Run preflight and rebuild the images:

```bash
make SNAPSHOT=true setup
```

For import mode instead:

```bash
make SNAPSHOT=false setup
```

`make start-reth` uses the compose file selected by `SNAPSHOT`. In snapshot mode the entrypoint is `download-snapshot.sh`. In import mode the entrypoint is `download-migration-files.sh`.

5. Start execution (reth) first:

```bash
make SNAPSHOT=true start-reth
```

For import mode instead:

```bash
make SNAPSHOT=false start-reth
```

6. Start op-node (this auto-starts EigenDA proxy first):

```bash
make SNAPSHOT=true start-op-node
```

For import mode instead:

```bash
make SNAPSHOT=false start-op-node
```

If reth or eigenda-proxy is not ready, `start-op-node` exits with a clear message. You can still run `make start-eigenda-proxy` manually for debugging.

Use the same `SNAPSHOT` value for follow-up commands such as `logs-*` and `stop-*` so `make` targets the same compose file.

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

If your snapshot or backup extracts into `DATADIR/mnt/...`, flatten it so the contents of `mnt` become the direct children of `DATADIR`. Reth should see `DATADIR/db/mdbx.dat`, not `DATADIR/mnt/db/mdbx.dat`.


## Rolling your own
If you'd like to roll your own images, the appropriate files will be available under:


https://storage.googleapis.com/conduit-networks-snapshots/saigon-testnet-cc58e966ql/latest.tar

https://storage.googleapis.com/conduit-networks-snapshots/ronin-mainnet-bfz9fadqzl/latest.tar

https://api.conduit.xyz/file/v1/optimism/genesis/saigon-testnet-cc58e966ql

https://api.conduit.xyz/file/v1/optimism/genesis/ronin-mainnet-bfz9fadqzl

https://storage.googleapis.com/conduit-public-dls/${NETWORK}-rollup.json


The snapshot and genesis URLs are selected from `NETWORK` in the entrypoint script. The snapshot archive may extract with a top-level `mnt/` directory, but the final runtime layout should be flattened into `DATADIR`.
