class_name Car
extends VehicleBody3D
## The player's car: a VehicleBody3D built entirely from primitives. Every
## physics tick it applies `control` and re-reads the surface under each wheel.

const MASS: float = 1200.0
const ENGINE_FORCE: float = 3200.0
const BRAKE_FORCE: float = 45.0
const HANDBRAKE_FORCE: float = 120.0
const MAX_STEER: float = 0.55
const STEER_FADE_SPEED: float = 35.0
const WHEEL_RADIUS: float = 0.36
const BODY_SIZE: Vector3 = Vector3(1.8, 0.55, 4.2)
const CABIN_SIZE: Vector3 = Vector3(1.5, 0.5, 2.0)
const WHEEL_OFFSETS: Array[Vector3] = [
	Vector3(0.85, 0.0, -1.45),
	Vector3(-0.85, 0.0, -1.45),
	Vector3(0.85, 0.0, 1.45),
	Vector3(-0.85, 0.0, 1.45),
]

var control: CarInput = CarInput.new()
var spec: StageSpec
var _wheels: Array[VehicleWheel3D] = []


func _ready() -> void:
	mass = MASS
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector3(0.0, -0.3, 0.0)
	_add_body()
	for offset: Vector3 in WHEEL_OFFSETS:
		_add_wheel(offset)


func _physics_process(delta: float) -> void:
	var speed: float = linear_velocity.length()
	var lock: float = MAX_STEER * clampf(1.0 - speed / STEER_FADE_SPEED, 0.35, 1.0)
	steering = CarInput.smoothed_steer(steering, -control.steer * lock, delta)
	# VehicleBody3D drives toward +Z on a positive force; negate so the car
	# travels along -Z like every other Node3D's "forward".
	engine_force = -control.throttle * ENGINE_FORCE
	brake = control.brake * BRAKE_FORCE
	_apply_surfaces()
	if control.handbrake:
		_wheels[2].brake = HANDBRAKE_FORCE
		_wheels[3].brake = HANDBRAKE_FORCE
		_wheels[2].wheel_friction_slip *= 0.4
		_wheels[3].wheel_friction_slip *= 0.4


func speed_kmh() -> float:
	return linear_velocity.length() * 3.6


func forward() -> Vector3:
	return -global_basis.z


func _apply_surfaces() -> void:
	if spec == null:
		return
	var drag: float = 0.0
	for wheel: VehicleWheel3D in _wheels:
		var kind: Surface.Kind = spec.surface_at(wheel.global_position)
		wheel.wheel_friction_slip = Surface.grip(kind)
		wheel.brake = 0.0
		drag += Surface.drag(kind) / _wheels.size()
	apply_central_force(-linear_velocity * drag * mass)


func _add_body() -> void:
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = BODY_SIZE
	shape.shape = box
	add_child(shape)
	add_child(_box_mesh(BODY_SIZE, Vector3.ZERO, Palette.CAR))
	add_child(_box_mesh(CABIN_SIZE, Vector3(0.0, 0.5, 0.3), Palette.INK))


func _add_wheel(offset: Vector3) -> void:
	var wheel: VehicleWheel3D = VehicleWheel3D.new()
	wheel.position = offset
	wheel.wheel_radius = WHEEL_RADIUS
	wheel.suspension_travel = 0.3
	wheel.suspension_stiffness = 45.0
	wheel.damping_compression = 0.9
	wheel.damping_relaxation = 0.6
	wheel.wheel_roll_influence = 0.05
	wheel.use_as_traction = true
	wheel.use_as_steering = offset.z < 0.0
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = WHEEL_RADIUS
	cylinder.bottom_radius = WHEEL_RADIUS
	cylinder.height = 0.3
	mesh.mesh = cylinder
	mesh.material_override = _flat(Palette.INK)
	mesh.rotation.z = PI / 2.0
	wheel.add_child(mesh)
	add_child(wheel)
	_wheels.push_back(wheel)


func _box_mesh(size: Vector3, offset: Vector3, colour: Color) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = offset
	mesh.material_override = _flat(colour)
	return mesh


func _flat(colour: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = colour
	return material
