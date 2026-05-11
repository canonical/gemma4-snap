# Copilot Instructions

This repository packages a large language model as a [Canonical Inference Snap](https://documentation.ubuntu.com/inference-snaps/) — a strictly confined Ubuntu snap that bundles a model CLI, a background inference server, and swappable hardware-specific engines.

The reference implementation for this pattern is [`nemotron-3-nano-snap`](https://github.com/canonical/nemotron-3-nano-snap), which this repo is modelled after.

## Architecture

The snap has three layers:

1. **Snap core** (`snap/snapcraft.yaml`): bundles the `modelctl`/CLI binary (from `canonical/inference-snaps-cli`), engine definitions, and startup scripts.
2. **Engines** (`engines/<name>/`): each engine has an `engine.yaml` (declaring required device, memory, disk, and which components to load) and a `server` shell script that launches the inference backend.
3. **Components** (`components/<name>/`): snap components distributed separately — inference binaries (`llama-cpp` for CPU, `llama-cpp-cuda` for NVIDIA GPU) and model weight shards (GGUF files split across multiple components due to Snap Store size limits). Model projector files are kept in separate components.

### Runtime flow

- On install, `snap/hooks/install` calls `modelctl use-engine --auto` to detect hardware and select the best engine.
- On snap refresh, `snap/hooks/post-refresh` calls `modelctl use-engine --fix` to reapply the active engine (or auto-select a new one if the previous engine was removed).
- The `server` daemon runs `bin/server.sh`, which calls `modelctl show-engine` to find the active engine, then `modelctl run <engine-server-script> --wait-for-components`.
- Each engine's `server` script reads `sleep-idle-seconds` config and `exec`s the llama-cpp component's own `server` binary (e.g., `$SNAP_COMPONENTS/llama-cpp/server`).
- The llama-cpp component's `server` reads `http.port`/`http.host` from config and launches `llama-server` with the `MODEL_FILE` path.

### Model sharding

Large GGUF models are split into numbered component shards (e.g., `model-...-1-of-6` through `6-of-6`). Because `llama-server` requires all shards in a single directory, the shard 1 `component.yaml` declares a `layout` section that instructs snapd to create symlinks from `/tmp/<model>-shards/` pointing to each shard across their individual component directories. `MODEL_FILE` (also set in shard 1's `component.yaml`) points to the first shard's symlink path.

### Component structure

**`components/llama-cpp/component.yaml`** and **`components/llama-cpp-cuda/component.yaml`** both declare:
- `servers: openai: protocol: http, base-path: /v1` — tells the inference framework this component exposes an OpenAI-compatible HTTP API
- `environment` — adds the component's `bin/` and `lib/` to `PATH`/`LD_LIBRARY_PATH`

**`components/model-.../component.yaml`** (shard 1 only) declares:
- `layout` — symlinks all shards into a flat `/tmp/<model>-shards/` directory via snapd
- `environment` — sets `MODEL_FILE` to the first shard's symlink path

### Key environment variables (set by components)

- `MODEL_FILE` — path to first model shard symlink (set in `components/model-.../component.yaml`)
- `SNAP_COMPONENTS` — path to installed components at runtime
- `ARCH_TRIPLET` — build architecture triplet (e.g., `x86_64-linux-gnu`)

## Build and install

Clone with submodules (the `dev/` submodule contains shared build/test scripts):
```shell
git clone --recurse-submodules <repo-url>
```

Model weight files (`.gguf`) are tracked via Git LFS. Pull them before building:
```shell
git lfs pull
```

Build the snap and all components:
```shell
./dev/build.sh
# or equivalently:
snapcraft pack -v
```

Install locally after building (connects required interfaces and optionally sets an engine):
```shell
./dev/install.sh [--engine=<engine>] [--clean]
# Example:
./dev/install.sh --engine=cpu-e4b --clean
```

## Upload

```shell
# Upload to latest/edge/<current-branch> by default
./dev/upload.sh

# Upload to a specific channel
./dev/upload.sh latest/edge/my-channel
```

## Smoke tests

Run against an installed snap (requires root, `curl`, and `yq` v4.x):
```shell
sudo ./dev/smoke-tests.sh <snap-name> <engine-name>
# Example:
sudo ./dev/smoke-tests.sh nemotron-3-nano cpu-e4b
```

Environment variable overrides: `CURL_TIMEOUT` (default 10s), `MAX_RETRIES` (default 60), `RETRY_DELAY` (default 60s).

## CI

- **`build-main.yaml`**: triggers on push to `main`; builds for `amd64` and `arm64` on self-hosted Ubuntu Noble (`xlarge`) runners; publishes to `latest/edge`.
- **`build-pr.yaml`**: triggered by adding the label defined in `vars.PR_BUILD_TRIGGER_LABEL`; publishes to `latest/edge/pr-<number>`.
- **`validate-engines.yaml`**: runs on every PR; checks out `canonical/inference-snaps-cli` and validates all `engines/**/*.yaml` manifests with `go run . debug validate-engines`.
- All build workflows delegate to the reusable `build-publish-snap.yaml` from the `dev` submodule (`canonical/inference-snaps-dev@v2`).
- The `init-build.sh` pre-build step runs `git lfs prune --force` to reduce disk usage on CI runners.

## Development

The `dev/` submodule contains shared scripts and GitHub Actions workflows for building, testing, and uploading inference snaps. This is added to the repo as a submodule from [`canonical/inference-snaps-dev`](https://github.com/canonical/inference-snaps-dev).

## Key conventions

- **Engine selection**: engines declare required devices with `anyof`/`allof` in `engine.yaml`; `modelctl use-engine --auto` matches these against detected hardware at install time.
- **Component naming in `snapcraft.yaml`**: component parts use `organize: "*": (component/<name>)` syntax to stage files into the component prime directory.
- **Model part lifecycle bypass**: model shards are copied directly in `override-prime` (skipping staging) to avoid duplicating large files on disk. Non-gguf files from shard 1's source directory (e.g., `component.yaml`, `README.md`) are also copied there; other shards get a placeholder `component.yaml`.
- **Daemon default config**: port `8336`, host `127.0.0.1`, verbose `false` — set in `snap/hooks/install`.
- **Renovate** (`renovate.json`): auto-updates `inference-snaps-cli` and `llama.cpp-builds` release URLs in `snapcraft.yaml` via regex custom managers, and tracks the `dev` submodule.
- **Issues and discussions** are managed in the upstream [`canonical/inference-snaps`](https://github.com/canonical/inference-snaps) repository, not this snap-specific repo.
