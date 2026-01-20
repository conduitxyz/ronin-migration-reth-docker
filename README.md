# ronin-migration-reth-docker

Dockerfile that can be used to run a reth node for the Ronin L1 -> L2 migration. This can be run as a typical reth node, with some extra parameters for the migration.

## Configuration parameters

Set the environment variable `DATADIR` to the same `--datadir` parameter you would pass into reth. This sets the datadir path for the initial state import.

## Saigon Migration

For the saigon testnet migration, specify the additional environment variable `NETWORK=saigon`

## Ronin Mainnet Migration

For the ronin mainnet migration, specify the additional environment variable `NETWORK=ronin`

## Troubleshooting

If you run into issues, try deleting the persistent data in your `--datadir` directory and restart the container image.
