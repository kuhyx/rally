#!/bin/bash

# ============================================================================
# Run the game natively. Extra arguments go to the game after `--`, e.g.
#   ./run.sh --seed=7 --autodrive --quit-on-finish
# ============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT

exec godot --path "$REPO_ROOT" -- "$@"
