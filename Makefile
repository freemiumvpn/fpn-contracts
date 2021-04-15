GO111MODULE=on 
GOPATH:=$(shell go env GOPATH)

BUILD_DIR=$(shell pwd)/build

# ----- Installing -----

.PHONY: install
install:
	go get google.golang.org/protobuf/cmd/protoc-gen-go
	go get google.golang.org/grpc/cmd/protoc-gen-go-grpc

# ----- Testing -----

BUILDENV := CGO_ENABLED=0
TESTFLAGS := -short -cover
SERVICE=fpn-contracts

.PHONY: test
test:
	mkdir -p $(BUILD_DIR)/vpn

	# Feedback
	protoc -I=./feedback --go_out=import_path=dummy:$(BUILD_DIR)/feedback feedback/*.proto
	protoc -I=./feedback --js_out=$(BUILD_DIR)/feedback feedback/*.proto

	# vpn
	protoc -I=./vpn --go_out=import_path=dummy:$(BUILD_DIR)/vpn vpn/*.proto
	protoc -I=./vpn --js_out=$(BUILD_DIR)/vpn vpn/*.proto


# ----- Docker -----

DOCKER_REGISTRY=freemiumvpn
DOCKER_CONTAINER_NAME=$(SERVICE)
DOCKER_REPOSITORY=$(DOCKER_REGISTRY)/$(DOCKER_CONTAINER_NAME)
SHA8=$(shell echo $(GITHUB_SHA) | cut -c1-8)

docker-image:
	docker build --rm \
		--build-arg SERVICE=$(SERVICE) \
		--tag $(DOCKER_REPOSITORY):local .

ci-docker-auth:
	@echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin

ci-docker-build:
	@docker build --rm \
		--build-arg SERVICE=$(SERVICE) \
		--tag $(DOCKER_REPOSITORY):$(SHA8) \
		--tag $(DOCKER_REPOSITORY):latest .

ci-docker-build-push: ci-docker-build
	@docker push $(DOCKER_REPOSITORY):$(SHA8)
	@docker push $(DOCKER_REPOSITORY):latest

