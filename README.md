# Gemma 4 snap
[![gemma4](https://snapcraft.io/gemma4/badge.svg)](https://snapcraft.io/gemma4)

Install [Gemma 4](https://ai.google.dev/gemma/docs/core/model_card_4), optimized directly for your hardware.
This package deploys a high-performance runtime for local inference across arm and x86 platforms. It runs efficiently on pure CPU or leverages hardware acceleration via NVIDIA, Intel, or AMD GPUs.

Before starting. get the necessary [drivers](https://documentation.ubuntu.com/inference-snaps/how-to/setup/drivers/) for using an accelerator.

**Install:**  
```
sudo snap install gemma4
```

**Use:**
```
gemma4 --help
```

## Resources

📚 **[Documentation](https://documentation.ubuntu.com/inference-snaps/)**, learn how to use inference snaps

💬 **[Discussions](https://github.com/canonical/inference-snaps/discussions)**, ask questions and share ideas

🐛 **[Issues](https://github.com/canonical/inference-snaps/issues)**, report bugs and request features

## Build and install from source

Clone this repo with its submodules:
```shell
git clone --recurse-submodules https://github.com/canonical/gemma4-snap
```

Prepare the required models by running `download-models.sh`.

Build the snap and its component:
```shell
snapcraft pack -v
```

Refer to the `./dev` directory for additional development tools.
