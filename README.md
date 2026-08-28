# Gemma 4 snap
[![gemma4](https://snapcraft.io/gemma4/badge.svg)](https://snapcraft.io/gemma4)

This snap installs a hardware-optimized engine for inference with
[Gemma 4 E4B](https://huggingface.co/google/gemma-4-E4B-it), Google's efficient
multimodal instruction-tuned model with vision capabilities.

## Resources

📚 **[Documentation](https://documentation.ubuntu.com/inference-snaps/)**, learn how to use inference snaps

💬 **[Discussions](https://github.com/canonical/inference-snaps/discussions)**, ask questions and share ideas

🐛 **[Issues](https://github.com/canonical/inference-snaps/issues)**, report bugs and request features

## Build and install from source

Clone the repo:
```shell
git clone https://github.com/canonical/gemma4-snap
cd gemma4-snap
```

Initialize the development environment:
```shell
make init
```

Build and install snap:
```shell
make build
make install
```

## Qualcomm Hexagon HTP

This branch contains an experimental ARM64 Qualcomm Hexagon HTP engine for
Gemma 4 E2B and E4B `Q4_0` model variants. Their multimodal projectors use
`Q8_0`, which is supported by the current HTP runtime. The existing `Q4_K_M`
models remain available for engines whose backends support that quantization.

The engine requires two platform contracts:

- `inference-npu`: a gadget-provided `custom-device` slot for the platform's
  NPU device nodes.
- `inference-npu-runtime-qcom-htp`: a versioned content provider containing
  the matching Qualcomm FastRPC host library and platform DSP
  configuration/files.

The device contract is platform-neutral. A Qualcomm gadget can map
FastRPC/CDSP nodes to it, while a future MediaTek or Renesas gadget can expose
its own device implementation through the same `inference-npu` plug. Runtime
content contracts are versioned by ABI and layout, so incompatible runtimes
use their own content contract rather than publishing incompatible files under
one identifier.

The Qualcomm engine remains experimental and is not selected automatically.
It can be selected after the required platform contracts are connected and the matching
runtime provider is installed. The draft consumes the tested artifact from
the development `llama.cpp-builds` release; that URL must move to the
canonical release after the artifact PR is merged and a new build release is
published.
