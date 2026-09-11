#!/bin/bash

# ============================================================================
# Install everything ~/rally depends on: Godot 4.7 + export templates, the
# Python dev tools (gdlint/gdformat, pre-commit, Playwright + Chromium for the
# web smoke test), the GUT test framework, and this repo's git hooks.
#
# Idempotent; rerun after a pull. GUT is cloned into addons/gut (gitignored)
# because its tree ships PNG icons and the no-binaries gate is absolute.
# ============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT
readonly GODOT_VERSION="4.7.2"
readonly GUT_TAG="v9.7.1"   # newest stable; not tracked by the freshness gate
readonly VENV="$REPO_ROOT/.venv"
readonly TEMPLATES_DIR="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable"

ensure_godot() {
    if ! command -v godot >/dev/null 2>&1; then
        echo "Installing godot..."
        sudo pacman -S --needed --noconfirm godot
    fi
    if [[ ! -f "$TEMPLATES_DIR/web_release.zip" ]]; then
        echo "Installing Godot ${GODOT_VERSION} export templates..."
        local tpz
        tpz="$(mktemp --suffix=.tpz)"
        curl -fsSL -o "$tpz" \
            "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
        local unpacked
        unpacked="$(mktemp -d)"
        unzip -q "$tpz" -d "$unpacked"    # a .tpz is a zip with a templates/ root
        mkdir -p "$TEMPLATES_DIR"
        mv "$unpacked"/templates/* "$TEMPLATES_DIR"/
        rm -rf "$tpz" "$unpacked"
    fi
}

ensure_python_tools() {
    # A repo-local venv: Arch's system Python is PEP 668 managed, and pinning
    # exact versions in the shared ~/.local would fight every other repo.
    echo "Installing Python dev tools into .venv (pins from requirements-dev.txt)..."
    if [[ ! -x "$VENV/bin/python" ]]; then
        python3 -m venv "$VENV"
    fi
    "$VENV/bin/python" -m pip install --quiet -r "$REPO_ROOT/requirements-dev.txt"
    # Debian/Ubuntu runners lack Chromium's shared libraries; --with-deps
    # apt-installs them there and is not supported (nor needed) on Arch.
    if command -v apt-get >/dev/null 2>&1; then
        "$VENV/bin/python" -m playwright install --with-deps chromium >/dev/null
    else
        "$VENV/bin/python" -m playwright install chromium >/dev/null
    fi
}

ensure_gut() {
    local gut_dir="$REPO_ROOT/addons/gut"
    if [[ -f "$gut_dir/plugin.cfg" ]] && grep -q "${GUT_TAG#v}" "$gut_dir/plugin.cfg"; then
        return
    fi
    echo "Installing GUT ${GUT_TAG}..."
    rm -rf "$gut_dir"
    local tmp
    tmp="$(mktemp -d)"
    git clone -q --depth 1 --branch "$GUT_TAG" https://github.com/bitwes/Gut "$tmp"
    mkdir -p "$REPO_ROOT/addons"
    mv "$tmp/addons/gut" "$gut_dir"
    rm -rf "$tmp"
}

import_project() {
    # Builds .godot/ (class cache, .uid files) so headless runs resolve class_name.
    godot --headless --path "$REPO_ROOT" --import >/dev/null 2>&1 || true
}

main() {
    ensure_godot
    ensure_python_tools
    ensure_gut
    import_project
    "$REPO_ROOT/scripts/install_hooks.sh"
    echo "rally: ready. Run ./run.sh"
}

main "$@"
