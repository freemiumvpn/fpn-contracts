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
test: test-vpn test-feedback

test-feedback:
	mkdir -p $(BUILD_DIR)/feedback
	# GO
	protoc \
		-I=./feedback \
		--go_out=$(BUILD_DIR)/feedback \
		feedback/*.proto

	# JS
	protoc \
		-I=./feedback \
		--js_out=$(BUILD_DIR)/feedback \
		feedback/*.proto

test-vpn:
	mkdir -p $(BUILD_DIR)/vpn
	# GO
	protoc -I=./vpn \
		--go_out=$(BUILD_DIR)/vpn \
		vpn/*.proto

	# JS
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

