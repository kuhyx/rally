# Design record

Decisions for the first playable slice (2026-09-11). Superseding one means a
new dated entry, not an edit.

## Scope

One seeded procedural stage of ~2 km, tarmac for the first 40 % then gravel,
third-person chase camera, keyboard + gamepad both live, stage clock with a
split every 500 m, best time per seed persisted. No damage, no co-driver, no
service park, no menus.

## Engine and physics

Godot 4.7.2, GDScript, GL Compatibility on native and web. Jolt Physics with
the built-in `VehicleBody3D` / `VehicleWheel3D` raycast vehicle, all-wheel
traction, front steering. Surfaces change `wheel_friction_slip` (tarmac 10.5,
gravel 4.5) and add a speed-proportional drag on gravel. Jolt runs in the web
export unchanged (verified by `tests/web_smoke.py`: the car covers ~220 m in
8 s of held throttle in headless Chromium).

## Stage generation

Random walk of 40 m steps from a seeded RNG; heading change per step is
bounded to ±0.35 rad and total heading to ±1.3 rad from +Z, so Z is monotonic
and the ribbon cannot cross itself. Elevation drifts ±2.5 m per step, clamped
to ±15 m. Control points become a `Curve3D` with chord-based tangents; every
lookup (`progress_at`, `surface_at`) is by baked offset.

## Determinism

Fixed 60 Hz physics, seeded RNG, no wall-clock reads in the sim. The
integration test runs the real game twice with `--fixed-fps 60` and asserts
identical finish times.

## Testing policy

GDScript has no coverage instrumentation, so the bar is: every pure script has
a GUT file exercising every public function and branch; nodes are covered by
the black-box autodrive run and the web smoke test. GUT is installed by
`install.sh`, not vendored, because it ships PNG icons.

## Known limits

- Trees are visual only (no collision).
- The grass ribbon is 160 m wide; beyond it the car falls and is reset to the
  start when it drops below y = -60.
- `scripts/perf.sh` needs a display, so CI does not run it; the recorded
  result on the dev PC (RTX 3090, 1080p, V-Sync off) was min 2327 fps.
