# ronin-migration-reth-docker

Dockerfile that can be used to run a reth node for the Ronin L1 -> L2 migration. This can be run as a typical reth node, with some extra parameters for the migration.

Note that you will need to run a consensus-layer client to power reth, typically `op-node`. Docs for running `op-node` are here: https://docs.optimism.io/node-operators/guides/configuration/consensus-clients

## Ronin-specific configuration parameters

### Reth
Set the environment variable `DATADIR` to the same `--datadir` parameter you would pass into reth. This sets the datadir path for the initial state import.

You will also need to set the `NETWORK=[saigon|ronin]` environment variable, depending on which network you are running the image for. For Saigon select `saigon`, for ronin mainnet select `ronin`.

### Op-node
The rollup.json file with automatically be downloaded, and environmental variable set, so no need to set the `--rollup.config` flag.

In addition the standard parameters, you will need to set the `OP_NODE_P2P_STATIC` variable.

For Saigon: `OP_NODE_P2P_STATIC=[tbd]`
For Ronin: `OP_NODE_P2P_STATIC=[tbd]`

## Troubleshooting

If you run into issues, try deleting the persistent data in your `--datadir` directory and restart the reth container image.
