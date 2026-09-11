#!/bin/bash

# ============================================================================
# Frame-rate gate: run the stage on screen at 1920x1080 with V-Sync off,
# autodriven so every run covers the same ground, and fail if the minimum
# FPS Godot reports (one sample per second) drops below MIN_FPS.
# Needs a display; the headless build does not render.
# ============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly MIN_FPS="${MIN_FPS:-60}"
readonly LOG="/tmp/rally-perf.log"

main() {
    godot --path "$REPO_ROOT" --resolution 1920x1080 --disable-vsync --print-fps \
        -- --seed=42 --autodrive --quit-on-finish >"$LOG" 2>&1
    local samples min avg
    samples="$(grep -c 'Project FPS' "$LOG" || true)"
    if [[ "$samples" -lt 10 ]]; then
        echo "perf: only $samples FPS samples; run did not complete" >&2
        exit 1
    fi
    # Skip the first two samples: they include scene build + shader warm-up.
    min="$(grep 'Project FPS' "$LOG" | tail -n +3 | awk '{print $3}' | sort -n | head -1)"
    avg="$(grep 'Project FPS' "$LOG" | tail -n +3 | awk '{s+=$3} END {printf "%d", s/NR}')"
    echo "perf: samples=$samples min=$min avg=$avg (gate: min >= $MIN_FPS)"
    if [[ "$min" -lt "$MIN_FPS" ]]; then
        echo "perf: FAIL" >&2
        exit 1
    fi
    echo "perf: ok"
}

main "$@"
