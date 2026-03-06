.PHONY: help preflight setup build-reth build-op-node start-reth start-eigenda-proxy start-op-node stop-reth stop-eigenda-proxy stop-op-node logs-reth logs-eigenda-proxy logs-op-node status

COMPOSE_FILE ?= docker-compose.yml
ENV_FILE ?= .env
COMPOSE = docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

help:
	@echo "Ronin migration workflow"
	@echo ""
	@echo "Usage:"
	@echo "  cp .env.example .env  # first time"
	@echo "  make setup"
	@echo "  make start-reth"
	@echo "  make start-op-node"
	@echo ""
	@echo "Targets:"
	@echo "  setup         Run preflight and build all images"
	@echo "  preflight     Validate env + prereqs and generate jwt.hex if missing"
	@echo "  build-reth    Build reth image"
	@echo "  build-op-node Build op-node image"
	@echo "  start-reth    Start only reth service"
	@echo "  start-op-node Auto-start eigenda-proxy, then start op-node"
	@echo "  start-eigenda-proxy Optional manual start for eigenda-proxy"
	@echo "  stop-reth     Stop only reth service"
	@echo "  stop-eigenda-proxy Stop only eigenda-proxy service"
	@echo "  stop-op-node  Stop only op-node service"
	@echo "  logs-reth     Tail reth logs"
	@echo "  logs-eigenda-proxy Tail eigenda-proxy logs"
	@echo "  logs-op-node  Tail op-node logs"
	@echo "  status        sync status"

preflight:
	@./scripts/preflight.sh $(ENV_FILE)

setup: preflight build-reth build-op-node

build-reth: preflight
	@$(COMPOSE) build execution

build-op-node: preflight
	@$(COMPOSE) build op-node

start-reth: preflight
	@$(COMPOSE) up -d execution
	@echo "reth started. watch logs with: make logs-reth"

start-eigenda-proxy: preflight
	@$(COMPOSE) up -d eigenda-proxy
	@echo "eigenda-proxy started. watch logs with: make logs-eigenda-proxy"

start-op-node: preflight
	@./scripts/check-reth-readiness.sh $(ENV_FILE)
	@$(COMPOSE) up -d eigenda-proxy
	@$(COMPOSE) up -d op-node
	@echo "op-node started. watch logs with: make logs-op-node"

stop-reth:
	@$(COMPOSE) stop execution

stop-eigenda-proxy:
	@$(COMPOSE) stop eigenda-proxy

stop-op-node:
	@$(COMPOSE) stop op-node

logs-reth:
	@$(COMPOSE) logs -f --tail=200 execution

logs-eigenda-proxy:
	@$(COMPOSE) logs -f --tail=200 eigenda-proxy

logs-op-node:
	@$(COMPOSE) logs -f --tail=200 op-node

status:
	@./scripts/status-op-node.sh $(ENV_FILE)
