.PHONY: help setup build-reth build-op-node start-reth start-op-node stop-reth stop-op-node logs-reth logs-op-node status

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
	@echo "  setup         Validate env + prereqs and generate jwt.hex if missing"
	@echo "  build-reth    Build reth image"
	@echo "  build-op-node Build op-node image"
	@echo "  start-reth    Start only reth service"
	@echo "  start-op-node Start only op-node service (fails fast if reth not ready)"
	@echo "  stop-reth     Stop only reth service"
	@echo "  stop-op-node  Stop only op-node service"
	@echo "  logs-reth     Tail reth logs"
	@echo "  logs-op-node  Tail op-node logs"
	@echo "  status        sync status"

setup:
	@./scripts/preflight.sh $(ENV_FILE)

build-reth: setup
	@$(COMPOSE) build execution

build-op-node: setup
	@$(COMPOSE) build op-node

start-reth: setup
	@$(COMPOSE) up -d execution
	@echo "reth started. watch logs with: make logs-reth"

start-op-node: setup
	@./scripts/check-reth-readiness.sh $(ENV_FILE)
	@$(COMPOSE) up -d op-node
	@echo "op-node started. watch logs with: make logs-op-node"

stop-reth:
	@$(COMPOSE) stop execution

stop-op-node:
	@$(COMPOSE) stop op-node

logs-reth:
	@$(COMPOSE) logs -f --tail=200 execution

logs-op-node:
	@$(COMPOSE) logs -f --tail=200 op-node

status:
	@./scripts/status-op-node.sh $(ENV_FILE)
