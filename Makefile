# Makefile

EDGELAKE_TYPE := generic
ifneq ($(filter-out $@,$(MAKECMDGOALS)), )
	EDGELAKE_TYPE = $(filter-out $@,$(MAKECMDGOALS))
endif

export DOCKER_IMAGE_BASE ?= anylogco/edgelake
export DOCKER_IMAGE_NAME ?= edgelake
export DOCKER_IMAGE_VERSION ?= latest

# DockerHub ID of the third party providing the image (usually yours if building and pushing)
export DOCKER_HUB_ID ?= anylogco
# The Open Horizon organization ID namespace where you will be publishing the service definition file
export HZN_ORG_ID ?= examples

# Open Horizon settings for publishing metadata about the service
export DEPLOYMENT_POLICY_NAME ?= deployment-policy-edgelake-$(EDGELAKE_TYPE)
export NODE_POLICY_NAME ?= node-policy-edgelake-$(EDGELAKE_TYPE)
export SERVICE_NAME ?= service-edgelake
export SERVICE_VERSION ?= $(shell curl -s https://raw.githubusercontent.com/EdgeLake/EdgeLake/main/setup.cfg | grep "version = " | awk -F " = " '{print $2}')

export ARCH := $(shell uname -m)
OS := $(shell uname -s)
ifeq ($(ARCH), arm64)
	export DOCKER_IMAGE_VERSION := latest-arm64
endif

export EDGELAKE_VOLUME := edgelake-$(EDGELAKE_TYPE)-anylog
export BLOCKCHAIN_VOLUME := edgelake-$(EDGELAKE_TYPE)-blockchain
export DATA_VOLUME := edgelake-$(EDGELAKE_TYPE)-data
export LOCAL_SCRIPTS_VOLUME := edgelake-$(EDGELAKE_TYPE)-local-scripts

all: help
build:
	docker pull anylogco/edgelake:latest
up:
	@echo "Deploy AnyLog with config file: anylog_$(EDGELAKE_TYPE).env"
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	@docker-compose -f docker_makefile/docker-compose.yaml up -d
	@rm -rf docker_makefile/docker-compose.yaml
down:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	@docker-compose -f docker_makefile/docker-compose.yaml down
	@rm -rf docker_makefile/docker-compose.yaml
clean:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	@docker-compose -f docker_makefile/docker-compose.yaml down -v --remove-orphans --rmi all
	@rm -rf docker_makefile/docker-compose.yaml
attach:
	docker attach --detach-keys=ctrl-d edgelake-$(EDGELAKE_TYPE)
node-status:
	@if [ "$(EDGELAKE_TYPE)" = "master" ]; then \
		curl -X GET 127.0.0.1:32049 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "operator" ]; then \
		curl -X GET 127.0.0.1:32149 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "query" ]; then \
		curl -X GET 127.0.0.1:32349 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(NODE_TYPE)" == "generic" ]; then \
		curl -X GET 127.0.0.1:32549 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	fi
test-node:
	@if [ "$(EDGELAKE_TYPE)" = "master" ]; then \
		curl -X GET 127.0.0.1:32049 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "operator" ]; then \
		curl -X GET 127.0.0.1:32149 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "query" ]; then \
		curl -X GET 127.0.0.1:32349 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(NODE_TYPE)" == "generic" ]; then \
		curl -X GET 127.0.0.1:32549 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	fi
test-network:
	@if [ "$(EDGELAKE_TYPE)" = "master" ]; then \
		curl -X GET 127.0.0.1:32049 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "operator" ]; then \
		curl -X GET 127.0.0.1:32149 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "query" ]; then \
		curl -X GET 127.0.0.1:32349 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(NODE_TYPE)" == "generic" ]; then \
		curl -X GET 127.0.0.1:32549 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	fi
exec:
	docker exec -it edgelake-$(EDGELAKE_TYPE) bash
logs:
	docker logs edgelake-$(EDGELAKE_TYPE)
help:
	@echo "Usage: make [target] [edgelake-type]"
	@echo "Targets:"
	@echo "  build       Pull the docker image"
	@echo "  up          Start the containers"
	@echo "  attach      Attach to EdgeLake instance"
	@echo "  test		 Using cURL validate node is running"
	@echo "  exec        Attach to shell interface for container"
	@echo "  down        Stop and remove the containers"
	@echo "  logs        View logs of the containers"
	@echo "  clean       Clean up volumes and network"
	@echo "  help        Show this help message"
	@echo "  supported EdgeLake types: generic, master, operator, and query"
	@echo "Sample calls: make up master | make attach master | make clean master"
