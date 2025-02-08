DOCKER_IMAGE_NAME := vaultwarden-serverless-builder

.PHONY: all build run tf-init tf-plan tf-apply

all: build run tf-init tf-plan tf-apply

build:
	docker build -t $(DOCKER_IMAGE_NAME) ./vaultwarden

run:
	docker run --rm --mount type=bind,source="./dist",target=/dist $(DOCKER_IMAGE_NAME)

tf-init:
	cd infra && terraform init

TF_VAR_FILE ?= vault.tfvars

tf-plan:
	cd infra && terraform plan -var-file="$(TF_VAR_FILE)"

tf-apply:
	cd infra && terraform apply -var-file="$(TF_VAR_FILE)"

tf-destroy:
	cd infra && terraform destroy -var-file="$(TF_VAR_FILE)"