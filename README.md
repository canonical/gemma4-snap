# Gemma 4 inference snap
[![gemma4](https://snapcraft.io/gemma4/badge.svg)](https://snapcraft.io/gemma4)

Gemma 4 E4B is Google's efficient multimodal instruction-tuned model with vision capabilities.

Use this snap to quickly install an optimized environment for local inference with Gemma 4.

The snap includes the following hardware-optimized inference engines:

* cpu: CPU-optimized for workstations
* nvidia-gpu: CUDA-optimized for workstation GPUs
* amd-gpu: ROCm-optimized for workstation GPUs
* intel-cpu: Optimized for Intel CPUs using OpenVINO Model Server
* intel-gpu: Optimized for Intel GPUs using OpenVINO Model Server
* intel-onemkl: Intel CPU-optimized for workstations using oneMKL (experimental)

The most suitable engine is automatically selected based on the available hardware.

#### Install
```shell
sudo snap install gemma4
```

#### Run
```shell
gemma4
```

> [!TIP]
> Some accelerators require extra [drivers](https://documentation.ubuntu.com/inference-snaps/how-to/setup/drivers/) to be usable with this snap.

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
