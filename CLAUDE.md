# CLAUDE.md — rally

Godot 4.7.2 / GDScript 3D rally time-trial. Remote: `github.com/kuhyx/rally`.
Read `README.md` for the commands; this file is the code map and the rules
that are not obvious from the code.

## Rules

- **Every GDScript warning is an error** (`project.godot [debug]`), including
  `inferred_declaration` and the `unsafe_*` family: no `:=`, every `var`,
  `const` and `for` iterator carries an explicit type, and every non-void
  return value is used or bound. `scripts/lint.sh` fails the commit otherwise.
- No `# gdlint:ignore` / warning-ignore annotations without asking first.
- 250 lines per file, code and prose (shared gate). Split, do not squeeze.
- No binaries. GUT lives in `addons/gut/` (gitignored) because it ships PNGs.
- Colours only from `Palette`; surfaces only through `Surface`.
- Godot is not tracked by the freshness gate: re-check
  github.com/godotengine/godot/releases when bumping `GODOT_VERSION` in
  `install.sh`, and `GUT_TAG` against bitwes/Gut.
- After adding a `class_name` script, run `godot --headless --path . --import`
  (lint.sh does this) or every user of it fails with "Could not find type".

## Code map (`scripts/`)

Pure (RefCounted / static, fully unit-tested):
- `palette.gd`, `surface.gd` — colours; surface grip/drag/colour/name.
- `seeded_rng.gd` — deterministic RNG wrapper.
- `launch_options.gd` — `--seed=N`, `--autodrive`, `--quit-on-finish`.
- `stage_spec.gd` — seed → `Curve3D` centreline, per-step surface, lookups
  (`progress_at`, `surface_at`, `tangent_at`, `start_transform`). Heading is
  bounded so Z is monotonic and the ribbon never self-intersects.
- `car_input.gd` — one frame of intent from an action-reader callable.
- `autodrive.gd` — pure-pursuit driver used by tests and the perf gate.
- `stage_timer.gd` — clock, splits, `format_time`, `is_best`.
- `save_store.gd` — best time per seed in `user://best_times.json`.
- `web_bridge.gd` — `window.__gameReady` / `window.__rally` on web only.

Nodes (thin):
- `stage_builder.gd` — road + grass ribbons (indexed triangles; the winding
  in `_ribbon` was verified empirically, the other order is culled and the
  car falls through), MultiMesh trees, start/finish gates.
- `car.gd` — `VehicleBody3D` from primitives; engine force is **negated**
  because Godot's vehicle drives toward +Z on a positive force.
- `chase_cam.gd`, `hud.gd`, `main.gd` — camera, text overlay, wiring.

## Verified traps

- `create_trimesh_shape()` needs `PRIMITIVE_TRIANGLES`; a strip gives no collider.
- Spawn at `StageSpec.START_OFFSET`, not offset 0: a car centred on the first
  edge hangs two wheels off the ribbon, tips and slides off.
- `--fixed-fps 60` runs headless faster than realtime *and* stays bit-identical
  to the realtime run (77.65 s on seed 42 both ways).
- Autodrive runs never write best times (they are not the player).
