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
| Reth | Docker image: https://github.com/conduitxyz/conduit-op-reth/pkgs/container/conduit-op-reth/684236333?tag=v1.0.0-rc.1 |

| **Reth Genesis File** | **Download** | md5 hash |
| --- | --- | --- |
| Saigon | [Link](https://api.conduit.xyz/file/v1/optimism/genesis/saigon-testnet-cc58e966ql) | 6cb46260ff4c48e7b15fa342ddb980d2  |

## Confirm Upgrade

Reth should log the fork timestamp at startup. 

If you see these logs on startup with the correct fork name `StateOverrideFork0` and timestamp `1771372800`, the upgrade was applied successfully.

**Saigon:**

```rs
│                                        Autoscroll:On      FullScreen:Off     Timestamps:Off     Wrap:Off                                         │
│ 2026-02-16T01:32:56.258514Z  INFO Initialized tracing, debug log directory: /root/.cache/reth/logs/202601                                        │
│ 2026-02-16T01:32:56.261935Z  INFO Starting Reth version="1.10.2-dev (8e3b5e6)"                                                                   │
│ 2026-02-16T01:32:56.262006Z  INFO Opening database path="/db/db"                                                                                 │
│ 2026-02-16T01:32:56.302373Z  INFO Launching conduit-op-reth node                                                                                 │
│ 2026-02-16T01:32:56.346110Z  INFO Configuration loaded path="/db/reth.toml"                                                                      │
│ 2026-02-16T01:32:56.464693Z  INFO Healing static file inconsistencies.                                                                           │
│ 2026-02-16T01:32:56.496488Z  INFO Verifying storage consistency.                                                                                 │
│ 2026-02-16T01:32:56.503452Z  INFO Database opened                                                                                                │
│ 2026-02-16T01:32:56.503497Z  INFO Storage settings settings=None                                                                                 │
│ 2026-02-16T01:32:56.528625Z  INFO Starting metrics endpoint at 0.0.0.0:6060                                                                      │
│ 2026-02-16T01:32:56.532286Z  INFO                                                                                                                │
│ Pre-merge hard forks (block based):                                                                                                              │
│ - Bedrock                          @0                                                                                                            │
│ Post-merge hard forks (timestamp based):                                                                                                         │
│ - Regolith                         @0                                                                                                            │
│ - Canyon                           @0                                                                                                            │
│ - Ecotone                          @0                                                                                                            │
│ - Fjord                            @0                                                                                                            │
│ - Granite                          @0                                                                                                            │
│ - Holocene                         @0                                                                                                            │
│ - Isthmus                          @0                                                                                                            │
│ - Jovian                           @0                                                                                                            │
│ - StateOverrideFork0               @1771372800                                                                                                   │
│ 2026-02-16T01:32:56.692765Z  INFO Transaction pool initialized                                                                                   │
│ 2026-02-16T01:32:57.790723Z  INFO P2P networking initialized enode=enode://053a0386052608b4c04fc596c3f28012deb740afaaeec0cd447aef7e43e6cbff9cc8b │
│ 2026-02-16T01:32:57.791853Z  INFO StaticFileProducer initialized                                                                                 │
│ 2026-02-16T01:32:57.822342Z  INFO Pruner initialized prune_config=PruneConfig { block_interval: 5, segments: PruneModes { sender_recovery: None, │
│ 2026-02-16T01:32:57.839291Z  INFO Consensus engine initialized                                                                                   │
│ 2026-02-16T01:32:57.839401Z  INFO Engine API handler initialized                                                                                 │
```