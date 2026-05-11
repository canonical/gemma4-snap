#!/bin/bash


# E2B model
wget -nv https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/resolve/main/gemma-4-E2B-it-Q4_K_M.gguf \
    --directory-prefix=components/model-e2b-q4-k-m-gguf/
wget -nv https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/resolve/main/mmproj-BF16.gguf \
    --directory-prefix=components/mmproj-e2b-bf16-gguf/

# E4B model
wget -nv https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-Q4_K_M.gguf \
    --directory-prefix=components/model-e4b-q4-k-m-gguf/
wget -nv https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/resolve/main/mmproj-gemma-4-E4B-it-Q8_0.gguf \
    --directory-prefix=components/mmproj-e4b-q8-0-gguf/

