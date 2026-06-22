#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
make "$@" download-all-models
