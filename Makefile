TAG ?= latest
IMAGE_NAME = s2i-haproxy-centos7:$(TAG)
DOCKER_OPTIONS ?= --pull
REGISTRY ?= quay.io/3scale

build: ## Build builder image
	docker build $(DOCKER_OPTIONS) --tag $(IMAGE_NAME) .


test: ## test image
	docker build -t $(IMAGE_NAME)-candidate .
	IMAGE_NAME=$(IMAGE_NAME)-candidate test/run
.PHONY: test

push: ## Push both builder and runtime image to the docker registry
	docker push $(REGISTRY)/$(IMAGE_NAME)
