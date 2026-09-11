class_name ChaseCam
extends Camera3D
## Third-person camera: sits behind and above the target's heading and eases
## toward that spot so cornering reads as motion instead of a rigid mount.

const BACK: float = 8.0
const UP: float = 3.2
const LOOK_UP: float = 1.0
const EASE: float = 5.0

var target: Node3D


func snap() -> void:
	if target != null:
		global_position = _desired()
		look_at(_focus(), Vector3.UP)


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var weight: float = 1.0 - exp(-EASE * delta)
	global_position = global_position.lerp(_desired(), weight)
	look_at(_focus(), Vector3.UP)


func _desired() -> Vector3:
	var heading: Vector3 = -target.global_basis.z
	heading.y = 0.0
	heading = heading.normalized()
	return target.global_position - heading * BACK + Vector3.UP * UP


func _focus() -> Vector3:
	return target.global_position + Vector3.UP * LOOK_UP
