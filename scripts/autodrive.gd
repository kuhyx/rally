class_name Autodrive
extends RefCounted
## Pure-pursuit driver: aims at a point LOOKAHEAD metres up the road and
## backs off the throttle in corners. Used by `--autodrive`, the perf run and
## the integration test, so it must finish every seed.

const LOOKAHEAD_MIN: float = 12.0
const LOOKAHEAD_PER_MS: float = 0.8
const STEER_GAIN: float = 2.2
const CORNER_SLOW_ANGLE: float = 0.25
const TOP_SPEED: float = 30.0

var _spec: StageSpec


func _init(spec: StageSpec) -> void:
	_spec = spec


func control(position: Vector3, forward: Vector3, speed: float) -> CarInput:
	var input: CarInput = CarInput.new()
	var progress: float = _spec.progress_at(position)
	var lookahead: float = LOOKAHEAD_MIN + speed * LOOKAHEAD_PER_MS
	var target: Vector3 = _spec.point_at(progress + lookahead)
	var angle: float = steer_angle(position, forward, target)
	input.steer = clampf(angle * STEER_GAIN, -1.0, 1.0)
	var bend: float = absf(angle)
	if speed > TOP_SPEED or (bend > CORNER_SLOW_ANGLE and speed > TOP_SPEED * 0.5):
		input.brake = 0.6
	else:
		input.throttle = 1.0
	return input


## Signed angle (radians) from `forward` to the target, flattened onto the
## ground plane. Positive means the target is to the right.
static func steer_angle(position: Vector3, forward: Vector3, target: Vector3) -> float:
	var to_target: Vector3 = target - position
	to_target.y = 0.0
	var flat_forward: Vector3 = Vector3(forward.x, 0.0, forward.z)
	if to_target.length_squared() == 0.0 or flat_forward.length_squared() == 0.0:
		return 0.0
	return -flat_forward.signed_angle_to(to_target, Vector3.UP)
