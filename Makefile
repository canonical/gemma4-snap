SHELL := /bin/bash

# Always run `hf` via pipx to avoid relying on local `hf` installations.
hf := pipx run --spec "huggingface_hub[cli]" hf

SNAP_NAME ?= gemma4
ENGINE ?= cpu

.PHONY: all help init init-submodules install-deps download-models \
	download-model-e2b download-model-e2b-qat \
	download-model-e4b download-model-e4b-qat \
	download-model-12b download-model-12b-qat \
	download-model-26b-a4b download-model-26b-a4b-qat \
	download-model-e4b-ov \
	build install upload smoke-test

all: help

#
# Main targets
#

help: ## Show this help message
	@echo "Usage: make <target>"
	@echo
	@echo "Targets:"
	@# List all targets with descriptions (lines starting with '##'):
	@grep -E '^[a-zA-Z0-9_-]+:.*## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  %-11s %s\n", $$1, $$2}'

init: init-submodules install-deps download-models ## Initialize the build environment (dependencies, model weights, submodules, etc.)

build: ## Build the snap
	./dev/build.sh

install: ## Install the snap
	./dev/install.sh

upload: ## Upload the snap
	./dev/upload.sh

smoke-test: ## Run smoke tests (override with SNAP_NAME=... ENGINE=...)
	sudo ./dev/smoke-test.sh $(SNAP_NAME) $(ENGINE)

#
# Supporting targets
#

install-deps:
	@echo "Installing dependencies..."
	@# Ensure pipx is available for running the hf CLI.
	@command -v pipx >/dev/null 2>&1 || { \
		sudo apt-get update; \
		sudo apt-get install -y pipx; \
	}

init-submodules:
	@echo "Initializing submodules..."
	@if git submodule status | grep -q '^-'; then \
		git submodule update --init; \
	fi

download-models: download-model-e2b download-model-e2b-qat download-model-e4b download-model-e4b-qat download-model-12b download-model-12b-qat download-model-26b-a4b download-model-26b-a4b-qat download-model-e4b-ov

download-model-e2b:
	@echo "Downloading Gemma 4 E2B model weights..."
	$(hf) download unsloth/gemma-4-E2B-it-GGUF gemma-4-E2B-it-Q4_K_M.gguf \
		--local-dir components/model-e2b-q4-k-m-gguf/
	$(hf) download unsloth/gemma-4-E2B-it-GGUF mmproj-BF16.gguf \
		--local-dir components/mmproj-e2b-bf16-gguf/

download-model-e2b-qat:
	@echo "Downloading Gemma 4 E2B QAT model weights..."
	$(hf) download unsloth/gemma-4-E2B-it-qat-GGUF gemma-4-E2B-it-qat-UD-Q4_K_XL.gguf \
		--local-dir components/model-e2b-qat-q4-k-xl-gguf/
	$(hf) download unsloth/gemma-4-E2B-it-qat-GGUF mmproj-BF16.gguf \
		--local-dir components/mmproj-e2b-qat-bf16-gguf/

download-model-e4b:
	@echo "Downloading Gemma 4 E4B model weights..."
	$(hf) download unsloth/gemma-4-E4B-it-GGUF gemma-4-E4B-it-Q4_K_M.gguf \
		--local-dir components/model-e4b-q4-k-m-gguf/
	$(hf) download unsloth/gemma-4-E4B-it-GGUF mmproj-BF16.gguf \
		--local-dir components/mmproj-e4b-bf16-gguf/

download-model-e4b-qat:
	@echo "Downloading Gemma 4 E4B QAT model weights..."
	$(hf) download unsloth/gemma-4-E4B-it-qat-GGUF gemma-4-E4B-it-qat-UD-Q4_K_XL.gguf \
		--local-dir components/model-e4b-qat-q4-k-xl-gguf/
	$(hf) download unsloth/gemma-4-E4B-it-qat-GGUF mmproj-BF16.gguf \
		--local-dir components/mmproj-e4b-qat-bf16-gguf/

download-model-12b:
	@echo "Downloading Gemma 4 12B model weights..."
	$(hf) download inference-snaps/gemma-4-12B-it-Q4_K_M-5GB \
		--local-dir components/model-12b-q4-k-m-gguf
	$(hf) download unsloth/gemma-4-12b-it-GGUF mmproj-BF16.gguf \
		--local-dir components/mmproj-12b-bf16-gguf/

download-model-12b-qat:
	@echo "Downloading Gemma 4 12B QAT model weights..."
	$(hf) download inference-snaps/gemma-4-12B-it-qat-UD-Q4_K_XL-5GB \
		--local-dir components/model-12b-qat-q4-k-xl-gguf
	$(hf) download unsloth/gemma-4-12B-it-qat-GGUF mmproj-BF16.gguf \
		--local-dir components/mmproj-12b-qat-bf16-gguf/

download-model-26b-a4b:
	@echo "Downloading Gemma 4 26B A4B model weights..."
	$(hf) download inference-snaps/gemma-4-26B-A4B-it-UD-Q4_K_M-5GB \
		--local-dir components/model-26b-a4b-q4-k-m-gguf
	$(hf) download unsloth/gemma-4-26B-A4B-it-GGUF mmproj-BF16.gguf \
		--local-dir components/mmproj-26b-bf16-gguf/

download-model-26b-a4b-qat:
	@echo "Downloading Gemma 4 26B A4B QAT model weights..."
	$(hf) download inference-snaps/gemma-4-26B-A4B-it-qat-UD-Q4_K_XL-5GB \
		--local-dir components/model-26b-a4b-qat-q4-k-xl-gguf
	$(hf) download unsloth/gemma-4-26B-A4B-it-qat-GGUF mmproj-BF16.gguf \
		--local-dir components/mmproj-26b-qat-bf16-gguf/

download-model-e4b-ov:
	@echo "Downloading Gemma 4 E4B OpenVINO model weights..."
	$(hf) download OpenVINO/gemma-4-E4B-it-int4-ov \
		--local-dir components/model-e4b-it-int4-ov/gemma4-e4b-it-int4-ov
	@echo "OVMS writes graph.pbtxt at runtime; pointing it to /tmp because component files are read-only..."
	ln -sf /tmp/graph.pbtxt ./components/model-e4b-it-int4-ov/gemma4-e4b-it-int4-ov/graph.pbtxt
