#!/bin/Makefile

EDGELAKE_TYPE := generic
ifneq ($(filter-out $@,$(MAKECMDGOALS)), )
	EDGELAKE_TYPE := $(filter-out $@,$(MAKECMDGOALS))
endif

# Docker configurations
export DOCKER_IMAGE_BASE ?= anylogco/edgelake
export DOCKER_IMAGE_NAME ?= edgelake
export DOCKER_HUB_ID ?= anylogco
export DOCKER_IMAGE_VERSION := 1.3.2407
ifeq ($(ARCH), arm64)
	export DOCKER_IMAGE_VERSION := 1.3.2407-arm64
endif

# Open Horizon Configs
export HZN_ORG_ID ?= myorg

# Node Deployment configs
export EDGELAKE_NODE_NAME := $(shell cat docker-makefiles/edgelake_${EDGELAKE_TYPE}.env | grep NODE_NAME | awk -F "=" '{print $$2}')
export EDGELAKE_VOLUME := $(EDGELAKE_NODE_NAME)-anylog
export BLOCKCHAIN_VOLUME := $(EDGELAKE_NODE_NAME)-blockchain
export DATA_VOLUME := $(EDGELAKE_NODE_NAME)-data
export LOCAL_SCRIPTS_VOLUME := $(EDGELAKE_NODE_NAME)-local-scripts

# Docker deployment call
DOCKER_COMPOSE := $(shell command -v docker-compose 2>/dev/null || echo "docker compose")

all: help-docker help-open-horizon
check:
	@echo "====================="
	@echo "ENVIRONMENT VARIABLES"
	@echo "====================="
	@echo "EDGELAKE_TYPE          default: generic                               actual: ${EDGELAKE_TYPE}"
	@echo "DOCKER_IMAGE_BASE      default: anylogco/edgelake                     actual: ${DOCKER_IMAGE_BASE}"
	@echo "DOCKER_IMAGE_NAME      default: edgelake                              actual: ${DOCKER_IMAGE_NAME}"
	@echo "DOCKER_IMAGE_VERSION   default: latest                                actual: ${DOCKER_IMAGE_VERSION}"
# 	@echo "DOCKER_VOLUME_NAME     default: homeassistant_config                  actual: ${DOCKER_VOLUME_NAME}"
	@echo "DOCKER_HUB_ID          default: anylogco                              actual: ${DOCKER_HUB_ID}"
	@echo "HZN_ORG_ID             default: myorg                                 actual: ${HZN_ORG_ID}"
# 	@echo "MY_TIME_ZONE           default: America/New_York                      actual: ${MY_TIME_ZONE}"
# 	@echo "DEPLOYMENT_POLICY_NAME default: deployment-policy-homeassistant       actual: ${DEPLOYMENT_POLICY_NAME}"
# 	@echo "NODE_POLICY_NAME       default: node-policy-homeassistant             actual: ${NODE_POLICY_NAME}"
# 	@echo "SERVICE_NAME           default: service-homeassistant                 actual: ${SERVICE_NAME}"
# 	@echo "SERVICE_VERSION        default: 0.0.1                                 actual: ${SERVICE_VERSION}"
# 	@echo "ARCH                   default: amd64                                 actual: ${ARCH}"
	@echo ""
	@echo "=================="
	@echo "SERVICE DEFINITION"
	@echo "=================="
#	@cat service.definition.json | envsubst
	@echo ""

build:
	@echo "Pulling image $(DOCKER_IMAGE_BASE):$(DOCKER_IMAGE_VERSION)"
    @$(DOCKER_COMPOSE) pull $(DOCKER_IMAGE_BASE):$(DOCKER_IMAGE_VERSION)

up:
    @echo "Deploying EdgeLake with config file: edgelake_$(EDGELAKE_TYPE).env"
    EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker-makefiles/docker-compose-template.yaml > docker-makefiles/docker-compose.yaml
	$(DOCKER_COMPOSE) -f docker-makefiles/docker-compose.yaml up -d
	@rm -rf docker-makefiles/docker-compose.yaml
down:
	@echo "Stopping EdgeLake with config file: edgelake_$(EDGELAKE_TYPE).env"
    EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker-makefiles/docker-compose-template.yaml > docker-makefiles/docker-compose.yaml
	$(DOCKER_COMPOSE) -f docker-makefiles/docker-compose.yaml down
	@rm -rf docker-makefiles/docker-compose.yaml
clean:
	@echo "Cleaning EdgeLake with config file: edgelake_$(EDGELAKE_TYPE).env"
    EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker-makefiles/docker-compose-template.yaml > docker-makefiles/docker-compose.yaml
	$(DOCKER_COMPOSE) -f docker-makefiles/docker-compose.yaml down -v --rmi all
	@rm -rf docker-makefiles/docker-compose.yaml
