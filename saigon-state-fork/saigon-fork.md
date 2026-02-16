# Saigon Fork Upgrade

This upgrade requires all node operators to update their Reth execution client and apply a new genesis file befoe the hardfork activates.

This is an **execution client only** hardfork.

> **WARNING**
All node operators must upgrade their Execution Client to continue following the chain.
> 

## Upgrade Timeline

| Date | Milestone |
| --- | --- |
| Wednesday, February 18, 2026 12:00:00 AM GMT (`1771372800`) | Saigon hardfork activates |

## Upgrade Details

- A **new reth genesis file** is required.
- **No configuration changes** are required.

## Upgrade Instructions

> 
1. **Stop the Reth client.**
2. **Install the recommended release version of Reth** (see Download Links below).
3. **Install the new genesis file** and verify the hash:
    
    ```bash
    md5sum <genesis-file>
    ```
    
4. **Start the Reth client replacing the `--chain` flag argument with the new genesis file.**

## Download Links

| Asset | **Docker image* |
| --- | --- |
| Reth |
Docker image: https://github.com/conduitxyz/conduit-op-reth/pkgs/container/conduit-op-reth/684236333?tag=v1.0.0-rc.1 |

| **Reth Genesis File** | **Download** | md5 hash |
| --- | --- | --- |
| Saigon | [Link](https://api.conduit.xyz/file/v1/optimism/genesis/saigon-testnet-cc58e966ql) | 6cb46260ff4c48e7b15fa342ddb980d2  |

## Confirm Upgrade

Reth should log the fork timestamp at startup. 

If you see these logs on startup with the correct fork name `StateOverrideFork0` and timestamp `1771372800`, the upgrade was applied successfully.

**Saigon:**