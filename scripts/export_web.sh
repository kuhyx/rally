#!/bin/bash

# ============================================================================
# Export the Web build to dist/ (preset "Web" in export_presets.cfg).
# ============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT

main() {
    rm -rf "$REPO_ROOT/dist" && mkdir -p "$REPO_ROOT/dist"
    godot --headless --path "$REPO_ROOT" --export-release Web dist/index.html
    ls -la "$REPO_ROOT/dist"
}

main "$@"
