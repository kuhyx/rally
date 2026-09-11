class_name StageSpec
extends RefCounted
## A rally stage derived entirely from a seed: a Curve3D centerline of about
## STAGE_LENGTH metres, one surface per control point, and lookups along it.
## Heading is kept within HEADING_LIMIT of +Z so Z is monotonic and the ribbon
## can never cross itself.

const STAGE_LENGTH: float = 2000.0
const STEP: float = 40.0
const WIDTH: float = 9.0
const HEADING_LIMIT: float = 1.3
const TURN_PER_STEP: float = 0.35
const CLIMB_PER_STEP: float = 2.5
const CLIMB_LIMIT: float = 15.0
const TARMAC_SHARE: float = 0.4
const FINISH_MARGIN: float = 10.0
const START_OFFSET: float = 8.0
const BAKE_INTERVAL: float = 1.0
const SHOULDER: float = 0.5

var curve: Curve3D = Curve3D.new()
var _surfaces: Array[Surface.Kind] = []
var _control_points: Array[Vector3] = []


func _init(seed_value: int) -> void:
	var rng: SeededRng = SeededRng.new(seed_value)
	var steps: int = ceili(STAGE_LENGTH / STEP)
	var position: Vector3 = Vector3.ZERO
	var heading: float = 0.0
	var climb: float = 0.0
	curve.bake_interval = BAKE_INTERVAL
	for i: int in range(steps + 1):
		_control_points.push_back(position)
		_surfaces.push_back(_surface_for(i, steps))
		heading = clampf(
			heading + rng.randf_range(-TURN_PER_STEP, TURN_PER_STEP), -HEADING_LIMIT, HEADING_LIMIT
		)
		climb = clampf(
			climb + rng.randf_range(-CLIMB_PER_STEP, CLIMB_PER_STEP), -CLIMB_LIMIT, CLIMB_LIMIT
		)
		var next: Vector3 = position + Vector3(sin(heading), 0.0, cos(heading)) * STEP
		next.y = climb
		position = next
	_build_curve()


func length() -> float:
	return curve.get_baked_length()


func control_points() -> Array[Vector3]:
	return _control_points


func point_at(offset: float) -> Vector3:
	return curve.sample_baked(clampf(offset, 0.0, length()))


func tangent_at(offset: float) -> Vector3:
	var ahead: Vector3 = point_at(offset + BAKE_INTERVAL)
	var behind: Vector3 = point_at(offset - BAKE_INTERVAL)
	return (ahead - behind).normalized()


func progress_at(position: Vector3) -> float:
	return curve.get_closest_offset(position)


## Off the ribbon (beyond half the width plus a small shoulder) is grass,
## whatever the road there is laid with.
func surface_at(position: Vector3) -> Surface.Kind:
	var offset: float = progress_at(position)
	var tangent: Vector3 = tangent_at(offset)
	var lateral: Vector3 = position - point_at(offset)
	# Drop the along-road component so the straight aprons past either end
	# (where progress clamps) still read as road, not grass.
	lateral -= tangent * lateral.dot(tangent)
	lateral.y = 0.0
	if lateral.length() > WIDTH * 0.5 + SHOULDER:
		return Surface.Kind.GRASS
	return surface_at_offset(offset)


func surface_at_offset(offset: float) -> Surface.Kind:
	var index: int = clampi(floori(offset / STEP), 0, _surfaces.size() - 1)
	return _surfaces[index]


func is_finished(progress: float) -> bool:
	return progress >= length() - FINISH_MARGIN


## Where the car spawns: START_OFFSET metres in, so no wheel hangs off the
## ribbon's first edge; -Z (Node3D forward) points down the road.
func start_transform() -> Transform3D:
	var forward: Vector3 = tangent_at(START_OFFSET)
	return Transform3D(Basis.looking_at(forward, Vector3.UP), point_at(START_OFFSET))


func _surface_for(index: int, steps: int) -> Surface.Kind:
	if index < int(steps * TARMAC_SHARE):
		return Surface.Kind.TARMAC
	return Surface.Kind.GRAVEL


func _build_curve() -> void:
	# Catmull-Rom style tangents: each control point's in/out handle points
	# along the chord between its neighbours, which keeps the road smooth.
	var count: int = _control_points.size()
	for i: int in range(count):
		var previous: Vector3 = _control_points[maxi(i - 1, 0)]
		var following: Vector3 = _control_points[mini(i + 1, count - 1)]
		var handle: Vector3 = (following - previous) * 0.25
		curve.add_point(_control_points[i], -handle, handle)
