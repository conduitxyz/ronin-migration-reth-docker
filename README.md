# Ronin Migration Docker Images (op-reth, op-node)

Dockerfiles that can be used to run a reth node for the Ronin L1 -> L2 migration. This can be run as a typical reth node, with some extra parameters for the migration.

Note that you will need to run a consensus-layer client to power reth, typically `op-node`. Docs for running `op-node` are here: https://docs.optimism.io/node-operators/guides/configuration/consensus-clients. We also include an `op-node` that should be used.

We expect the testnet migration to take ~3 hours, and the mainnet migration to take ~7 hours.

## Ronin-specific configuration parameters

### Reth
Set the environment variable `DATADIR` to the same `--datadir` parameter you would pass into reth. This sets the datadir path for the initial state import.

You will also need to set the `NETWORK=[saigon|ronin]` environment variable, depending on which network you are running the image for. For Saigon select `saigon`, for ronin mainnet select `ronin`.

### Op-node
The rollup.json file with automatically be downloaded, and environmental variable set, so no need to set the `--rollup.config` flag.

In addition the standard parameters, you will need to set the `OP_NODE_P2P_STATIC` variable.

For Saigon: `OP_NODE_P2P_STATIC=/ip4/34.187.134.72/tcp/9222/p2p/16Uiu2HAmFyGhL6G7CRgc77zmEeWAdBJA2vFsY9LSYzJQfnCrpWUW`

For Ronin: `OP_NODE_P2P_STATIC=[tbd]`

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
