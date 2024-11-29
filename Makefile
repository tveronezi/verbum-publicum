SHELL := /bin/bash

include sample.env
export

ifneq (,$(wildcard .env))
    include .env
    export
endif

DIRECTORIES := \
    modules/namespaces \
    modules/wordpress

.PHONY: \
    init \
    apply \
    destroy-wordpress \
    scaledown \
    scaleup \
    wp-cli \
    fmt \
    ci

init:
	@set -e; \
	for dir in $(DIRECTORIES); do \
	  echo "Initializing Terraform in $$dir"; \
	  (cd $$dir && terraform init -upgrade); \
	done

apply:
	@set -e; \
	for dir in $(DIRECTORIES); do \
	  echo "Applying Terraform in $$dir"; \
	  (cd $$dir && terraform apply -auto-approve); \
	done

destroy-wordpress:
	@set -e; \
	(cd modules/wordpress && terraform destroy -auto-approve)

scaledown:
	kubectl -n "${TF_VAR_wordpress_namespace}" scale deployment wordpress --replicas=0
	kubectl -n "${TF_VAR_wordpress_namespace}" scale statefulset wordpress-mariadb --replicas=0

scaleup:
	kubectl -n "${TF_VAR_wordpress_namespace}" scale deployment wordpress --replicas=1
	kubectl -n "${TF_VAR_wordpress_namespace}" scale statefulset wordpress-mariadb --replicas=1

wp-cli:
	kubectl -n "${TF_VAR_wordpress_namespace}" exec -c wordpress -it deploy/wordpress -- wp $(filter-out $@,$(MAKECMDGOALS))

%:
	@:

fmt:
	@for dir in $(DIRECTORIES); do \
	  echo "Formatting Terraform files in $$dir"; \
	  (cd $$dir && terraform fmt); \
	done

ci: init
	@for dir in $(DIRECTORIES); do \
	  echo "Validating Terraform in $$dir"; \
	  (cd $$dir && terraform fmt -check && terraform validate); \
	done
