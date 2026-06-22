#!/usr/bin/make -f

SHELL := /bin/bash

.PHONY: download-all-models download-e2b-model download-e4b-model download-26b-mmproj download-26b-model download-e4b-openvino-model setup-hf-cli

download-all-models: download-e2b-model download-e4b-model download-26b-mmproj download-26b-model download-e4b-openvino-model

download-e2b-model:
	wget -nv https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/resolve/main/gemma-4-E2B-it-Q4_K_M.gguf \
		--directory-prefix=components/model-e2b-q4-k-m-gguf/
	wget -nv https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/resolve/main/mmproj-BF16.gguf \
		--directory-prefix=components/mmproj-e2b-bf16-gguf/

download-e4b-model:
	wget -nv https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-Q4_K_M.gguf \
		--directory-prefix=components/model-e4b-q4-k-m-gguf/
	wget -nv https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/resolve/main/mmproj-gemma-4-E4B-it-Q8_0.gguf \
		--directory-prefix=components/mmproj-e4b-q8-0-gguf/

download-26b-mmproj:
	wget -nv https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF/resolve/main/mmproj-BF16.gguf \
		--directory-prefix=components/mmproj-26b-bf16-gguf/

setup-hf-cli:
	sudo apt-get install -y python3-venv
	python3 -m venv .venv
	. .venv/bin/activate && pip install --upgrade pip && pip install -U huggingface_hub

download-26b-model: setup-hf-cli
	. .venv/bin/activate && hf download inference-snaps/gemma-4-26B-A4B-it-UD-Q4_K_M-5GB --local-dir components/model-26b-a4b-q4-k-m-gguf
	ls components/model-26b-a4b-q4-k-m-gguf

download-e4b-openvino-model: setup-hf-cli
	. .venv/bin/activate && hf download OpenVINO/gemma-4-E4B-it-int4-ov --local-dir components/model-e4b-it-int4-ov/gemma4-e4b-it-int4-ov
	ln -sf /tmp/graph.pbtxt ./components/model-e4b-it-int4-ov/gemma4-e4b-it-int4-ov/graph.pbtxt