# rally

3D rally time-trial: one seeded procedural stage (tarmac into gravel), a
primitive-built car on Godot's `VehicleBody3D` + Jolt, chase camera, stage
clock with splits and a persisted best time. Godot 4.7.2, GDScript, GL
Compatibility renderer on every target. Runs natively on Linux and as a web
export. No art assets: every mesh is a primitive, every colour is in
`scripts/palette.gd`.

## Quick start

```
./install.sh        # godot + export templates, gdtoolkit/playwright venv, GUT, git hooks
./run.sh            # play (WASD / arrows, Space handbrake, R restart, Esc quit; gamepad too)
./run.sh --seed=7   # a different stage
```

`--autodrive` lets the built-in driver take the wheel; `--quit-on-finish`
prints `FINISH <seconds>` and exits (what the tests and the perf gate use).

## Gates

| command | what it proves |
|---|---|
| `scripts/lint.sh` | gdlint (every check), gdformat, headless parse with **all GDScript warnings as errors** |
| `scripts/test.sh` | GUT: unit tests for every pure script + an integration run of the real game (`--fixed-fps`, 78 sim-seconds in ~2 s) that asserts determinism |
| `scripts/check.sh` | lint + test + the four shared gates (250-line cap, markdown naming, no binaries, dependency freshness) |
| `scripts/perf.sh` | on-screen 1080p autodrive run, V-Sync off; fails if min FPS < 60 |
| `scripts/export_web.sh && .venv/bin/python tests/web_smoke.py` | exports `dist/`, boots it in headless Chromium, holds W and asserts the car moved and the canvas is not blank |

Pre-commit runs the shared gates; CI (`.github/workflows/`) runs everything
except `perf.sh`, which needs a display.

## Layout

```
scripts/*.gd      game code (see CLAUDE.md for the map)
scripts/*.sh      the gates above + shims over ~/utils
tests/unit/       one GUT file per pure script
tests/integration/ black-box autodrive runs
tests/web_smoke.py Playwright check of the web export
addons/gut/       installed by install.sh, gitignored (ships PNGs)
```
