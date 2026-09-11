class_name CarInput
extends RefCounted
## One frame of driver intent, in [0,1] / [-1,1]. Built from an action reader
## callable so the same code serves real Input, the autodriver and tests.

const STEER_RATE: float = 6.0

var throttle: float = 0.0
var brake: float = 0.0
var steer: float = 0.0
var handbrake: bool = false


## `strength` takes an action name and returns its strength in [0,1].
static func from_actions(strength: Callable) -> CarInput:
	var input: CarInput = CarInput.new()
	input.throttle = _strength(strength, "throttle")
	input.brake = _strength(strength, "brake")
	input.steer = _strength(strength, "steer_right") - _strength(strength, "steer_left")
	input.handbrake = _strength(strength, "handbrake") > 0.5
	return input


## Keyboard steering is digital; ease the wheel toward the target so the car
## does not snap to full lock in one frame.
static func smoothed_steer(previous: float, target: float, delta: float) -> float:
	return move_toward(previous, target, STEER_RATE * delta)


static func _strength(strength: Callable, action: String) -> float:
	var value: float = strength.call(action)
	return clampf(value, 0.0, 1.0)
