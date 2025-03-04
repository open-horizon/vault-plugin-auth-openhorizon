SHELL := /bin/bash

# Get Arch for tag and hardware (Golang style) to run test
arch_tag ?= $(shell ./tools/arch-tag)
arch ?= $(arch_tag)

VAULT_VERSION := 1.14.8 #[CRITICAL] DO NOT CHANGE!
VAULT_GPGKEY ?= C874011F0AB405110D02105534365D9472D7468F
VAULT_PLUGIN_HASH := ""

EXECUTABLE := vault-plugin-auth-openhorizon
DOCKER_INAME ?= openhorizon/$(arch)_vault
VERSION ?= 1.2.0
DEV_VERSION ?=testing
DOCKER_IMAGE_LABELS ?= --label "name=$(arch)_vault" --label "version=$(VERSION)" --label "vault_version=$(VAULT_VERSION)" --label "release=$(shell git rev-parse --short HEAD)"

DOCKER_DEV_OPTS ?=

GOOS ?= linux
GOARCH ?= amd64
COMPILE_ARGS ?= CGO_ENABLED=$(CGO_ENABLED) GOARCH=$(GOARCH) GOOS=$(GOOS)

ifndef verbose
.SILENT:
endif

.PHONY: all
all: clean vault-image

.PHONY: dev
dev: vault-dev-image

.PHONY: format
format:
	@echo "Formatting all Golang source code with gofmt"
	find . -name '*.go' -exec gofmt -l -w {} \;

./bin/$(EXECUTABLE): $(shell find . -name '*.go')
	@echo "Producing $(EXECUTABLE) for arch: amd64"
	$(COMPILE_ARGS) go build -o ./bin/$(EXECUTABLE)

.PHONY: dev-goreleaser
#dev-goreleaser: export GPG_KEY_FILE := /dev/null
dev-goreleaser: export GITHUB_REPOSITORY_OWNER = none
dev-goreleaser: export RELEASE_BUILD_GOOS = linux
dev-goreleaser:
	goreleaser release --clean --timeout=60m --verbose --parallelism 2 --snapshot --skip sbom,sign

.PHONY: vault-image
vault-image: ./bin/$(EXECUTABLE)
	@echo "Handling $(DOCKER_INAME):$(VERSION) with hash $(VAULT_PLUGIN_HASH)"
	if [ -n "$(shell docker images | grep '$(DOCKER_INAME):$(VERSION)')" ]; then \
		echo "Skipping since $(DOCKER_INAME):$(VERSION) image exists, run 'make clean && make' if a rebuild is desired"; \
	elif [[ $(arch) == "amd64" ]]; then \
		echo "Building container image $(DOCKER_INAME):$(VERSION)"; \
		docker build --rm --no-cache --build-arg ARCH=$(arch) --build-arg VAULT_GPGKEY=$(VAULT_GPGKEY) --build-arg VAULT_PLUGIN_HASH=$(shell shasum -a 256 ./bin/$(EXECUTABLE) | awk '{ print $$1 }') $(DOCKER_IMAGE_LABELS) -t $(DOCKER_INAME):$(VERSION) -f docker/Dockerfile.ubi.$(arch) .; \
	else echo "Building the vault docker image is not supported on $(arch)"; fi

.PHONY: vault-dev-image
vault-dev-image:
	@echo "Handling $(DOCKER_INAME):$(DEV_VERSION)"
	if [ -n "$(shell docker images | grep '$(DOCKER_INAME):$(DEV_VERSION)')" ]; then \
		echo "Skipping since $(DOCKER_INAME):$(DEV_VERSION) image exists, run 'make clean && make' if a rebuild is desired"; \
	elif [[ $(arch) == "amd64" ]]; then \
		echo "Building container image $(DOCKER_INAME):$(DEV_VERSION)"; \
		docker build --rm --no-cache --build-arg ARCH=$(arch) --build-arg VAULT_GPGKEY=$(VAULT_GPGKEY) --build-arg VAULT_PLUGIN_HASH=$(shell shasum -a 256 ./bin/$(EXECUTABLE) | awk '{ print $$1 }')  $(DOCKER_IMAGE_LABELS) -t $(DOCKER_INAME):$(DEV_VERSION) -f docker/Dockerfile.ubi.$(arch) .; \
	else echo "Building the vault docker image is not supported on $(arch)"; fi

.PHONY: test
test:
	@echo "Executing unit tests"
	-@$(COMPILE_ARGS) go test -cover -tags=unit

.PHONY: clean
clean:
	rm -f ./bin/$(EXECUTABLE)
	-@docker rmi $(DOCKER_INAME):$(VERSION) 2> /dev/null || :
	-@docker rmi $(DOCKER_INAME):testing 2> /dev/null || :
