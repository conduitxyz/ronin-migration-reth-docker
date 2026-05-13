.PHONY: help preflight setup build-reth build-op-node start-reth start-eigenda-proxy start-op-node stop-reth stop-eigenda-proxy stop-op-node stop-all logs-reth logs-eigenda-proxy logs-op-node status

ifeq ($(origin SNAPSHOT), undefined)
SNAPSHOT := $(shell sed -n 's/^SNAPSHOT=//p' .env 2>/dev/null | head -n 1 | tr -d '[:space:]')
endif
SNAPSHOT ?= true
SNAPSHOT := $(strip $(SNAPSHOT))

ifeq ($(origin COMPOSE_FILE), undefined)
ifeq ($(SNAPSHOT),false)
COMPOSE_FILE := docker-compose-import.yml
MODE_NAME := import
else
COMPOSE_FILE := docker-compose.yml
MODE_NAME := snapshot
endif
endif

COMPOSE = docker compose --env-file .env -f $(COMPOSE_FILE)

help:
	@echo "Ronin migration workflow"
	@echo ""
	@echo "Usage:"
	@echo "  cp .env.example .env  # first time"
	@echo "  make SNAPSHOT=true setup"
	@echo "  make SNAPSHOT=true start-reth"
	@echo "  make SNAPSHOT=false start-reth"
	@echo ""
	@echo "Targets:"
	@echo "  setup         Run preflight and rebuild the images"
	@echo "  preflight     Validate env + prereqs and generate jwt.hex if missing"
	@echo "  build-reth    Build reth image"
	@echo "  build-op-node Build op-node image"
	@echo "  start-reth    Start only reth service"
	@echo "  start-op-node Auto-start eigenda-proxy, then start op-node"
	@echo "  start-eigenda-proxy Optional manual start for eigenda-proxy"
	@echo "  stop-reth     Stop only reth service"
	@echo "  stop-eigenda-proxy Stop only eigenda-proxy service"
	@echo "  stop-op-node  Stop only op-node service"
	@echo "  stop-all      Stop reth -> eigenda-proxy -> op-node"
	@echo "  logs-reth     Tail reth logs"
	@echo "  logs-eigenda-proxy Tail eigenda-proxy logs"
	@echo "  logs-op-node  Tail op-node logs"
	@echo "  status        sync status"

preflight:
	@./scripts/preflight.sh

setup: preflight build-reth build-op-node

build-reth: preflight
	@echo "building execution image with $(COMPOSE_FILE) ($(MODE_NAME) mode)"
	@$(COMPOSE) build execution

build-op-node: preflight
	@$(COMPOSE) build op-node

start-reth: preflight
	@echo "starting reth with $(COMPOSE_FILE) ($(MODE_NAME) mode)"
	@$(COMPOSE) up -d execution
	@echo "reth started. watch logs with: make logs-reth"

start-eigenda-proxy: preflight
	@$(COMPOSE) up -d eigenda-proxy
	@echo "eigenda-proxy started. watch logs with: make logs-eigenda-proxy"

start-op-node: preflight
	@./scripts/check-reth-readiness.sh
	@$(COMPOSE) up -d eigenda-proxy
	@$(COMPOSE) up -d op-node
	@echo "op-node started with $(COMPOSE_FILE) ($(MODE_NAME) mode). watch logs with: make logs-op-node"

stop-reth:
	@$(COMPOSE) stop execution

stop-eigenda-proxy:
	@$(COMPOSE) stop eigenda-proxy

stop-op-node:
	@$(COMPOSE) stop op-node

stop-all: stop-op-node stop-eigenda-proxy stop-reth 

logs-reth:
	@$(COMPOSE) logs -f --tail=200 execution

logs-eigenda-proxy:
	@$(COMPOSE) logs -f --tail=200 eigenda-proxy

logs-op-node:
	@$(COMPOSE) logs -f --tail=200 op-node

status:
	@./scripts/sync-status.sh
