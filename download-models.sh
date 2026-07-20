#!/bin/bash

set -euo pipefail

# Python venv with huggingface_hub
sudo apt-get install -y python3-venv

python3 -m venv .venv
source .venv/bin/activate

pip install --upgrade pip
pip install -U huggingface_hub

# E2B model
hf download unsloth/gemma-4-E2B-it-GGUF gemma-4-E2B-it-Q4_K_M.gguf \
    --local-dir components/model-e2b-q4-k-m-gguf/
hf download unsloth/gemma-4-E2B-it-GGUF mmproj-BF16.gguf \
    --local-dir components/mmproj-e2b-bf16-gguf/

# E4B model
hf download unsloth/gemma-4-E4B-it-GGUF gemma-4-E4B-it-Q4_K_M.gguf \
    --local-dir components/model-e4b-q4-k-m-gguf/
hf download unsloth/gemma-4-E4B-it-GGUF mmproj-BF16.gguf \
    --local-dir components/mmproj-e4b-bf16-gguf/

# 26B A4B model
hf download inference-snaps/gemma-4-26B-A4B-it-UD-Q4_K_M-5GB \
    --local-dir components/model-26b-a4b-q4-k-m-gguf
ls components/model-26b-a4b-q4-k-m-gguf
# 26B A4B mmproj
hf download unsloth/gemma-4-26B-A4B-it-GGUF mmproj-BF16.gguf \
    --local-dir components/mmproj-26b-bf16-gguf/

# OpenVINO E4B model
hf download OpenVINO/gemma-4-E4B-it-int4-ov \
    --local-dir components/model-e4b-it-int4-ov/gemma4-e4b-it-int4-ov
ln -sf /tmp/graph.pbtxt ./components/model-e4b-it-int4-ov/gemma4-e4b-it-int4-ov/graph.pbtxt
