class_name StageBuilder
extends Node3D
## Turns a StageSpec into geometry: a vertex-coloured road ribbon with a
## concave collider, a wide grass ribbon under it, trees (MultiMesh, visual
## only) and the start/finish gates. Everything is primitives; no assets.

const SAMPLE_STEP: float = 2.0
const APRON: float = 120.0
const GRASS_WIDTH: float = 160.0
const GRASS_DROP: float = 0.04
const TREE_SPACING: float = 18.0
const TREE_MIN_OFFSET: float = 9.0
const TREE_MAX_OFFSET: float = 45.0
const GATE_HEIGHT: float = 5.0


func build(spec: StageSpec, seed_value: int) -> void:
	var grass: Callable = func(_at: float) -> Color: return Palette.GRASS
	var road: Callable = func(at: float) -> Color: return Surface.color(spec.surface_at_offset(at))
	add_child(_ribbon(spec, GRASS_WIDTH, -GRASS_DROP, grass))
	add_child(_ribbon(spec, StageSpec.WIDTH, 0.0, road))
	_add_trees(spec, SeededRng.new(seed_value))
	add_child(_gate(spec, 0.0))
	add_child(_gate(spec, spec.length() - StageSpec.FINISH_MARGIN))


## `tint` maps a centreline offset to the vertex colour at that point.
## Indexed triangles (not a strip): the trimesh collider only reads triangles.
func _ribbon(spec: StageSpec, width: float, lift: float, tint: Callable) -> StaticBody3D:
	var surface_tool: SurfaceTool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	# APRON metres of straight run-off before the start and past the finish,
	# extrapolated along the end tangents, so braking after the flag never
	# drops the car off the edge of the world.
	var total: float = spec.length()
	var rows: int = ceili((total + 2.0 * APRON) / SAMPLE_STEP) + 1
	for row: int in range(rows):
		var at: float = minf(row * SAMPLE_STEP - APRON, total + APRON)
		var clamped: float = clampf(at, 0.0, total)
		var tangent: Vector3 = spec.tangent_at(clamped)
		var centre: Vector3 = spec.point_at(clamped) + tangent * (at - clamped) + Vector3.UP * lift
		var right: Vector3 = tangent.cross(Vector3.UP).normalized() * width * 0.5
		var colour: Color = tint.call(clamped)
		for side: float in [-1.0, 1.0]:
			surface_tool.set_color(colour)
			surface_tool.set_normal(Vector3.UP)
			surface_tool.add_vertex(centre + right * side)
	for row: int in range(rows - 1):
		var base: int = row * 2
		# Verified empirically (renderer + Jolt ray probe): this order makes
		# the ribbon face upward; the other one is culled and falls through.
		for index: int in [base, base + 2, base + 1, base + 1, base + 2, base + 3]:
			surface_tool.add_index(index)
	var mesh: ArrayMesh = surface_tool.commit()
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = _vertex_colour_material()
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var trimesh: ConcavePolygonShape3D = mesh.create_trimesh_shape()
	trimesh.backface_collision = true
	shape.shape = trimesh
	body.add_child(shape)
	body.add_child(instance)
	return body


func _add_trees(spec: StageSpec, rng: SeededRng) -> void:
	var trunks: MultiMesh = _multimesh(_cylinder(0.3, 0.3, 2.5), Palette.TRUNK)
	var crowns: MultiMesh = _multimesh(_cylinder(0.0, 2.2, 5.0), Palette.TREE)
	var count: int = floori(spec.length() / TREE_SPACING)
	trunks.instance_count = count
	crowns.instance_count = count
	for i: int in range(count):
		var at: float = i * TREE_SPACING
		var side: float = -1.0 if rng.randi_range(0, 1) == 0 else 1.0
		var distance: float = rng.randf_range(TREE_MIN_OFFSET, TREE_MAX_OFFSET) * side
		var right: Vector3 = spec.tangent_at(at).cross(Vector3.UP).normalized()
		var base: Vector3 = spec.point_at(at) + right * distance
		trunks.set_instance_transform(i, Transform3D(Basis.IDENTITY, base + Vector3.UP * 1.25))
		crowns.set_instance_transform(i, Transform3D(Basis.IDENTITY, base + Vector3.UP * 5.0))
	add_child(_multimesh_instance(trunks))
	add_child(_multimesh_instance(crowns))


func _gate(spec: StageSpec, at: float) -> Node3D:
	var gate: Node3D = Node3D.new()
	var right: Vector3 = spec.tangent_at(at).cross(Vector3.UP).normalized()
	var centre: Vector3 = spec.point_at(at)
	var half: float = StageSpec.WIDTH * 0.5 + 1.0
	for side: float in [-1.0, 1.0]:
		var post: MeshInstance3D = MeshInstance3D.new()
		post.mesh = _cylinder(0.2, 0.2, GATE_HEIGHT)
		post.material_override = _flat(Palette.GATE)
		post.position = centre + right * half * side + Vector3.UP * GATE_HEIGHT * 0.5
		gate.add_child(post)
	var bar: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(half * 2.0, 0.4, 0.4)
	bar.mesh = box
	bar.material_override = _flat(Palette.GATE)
	bar.position = centre + Vector3.UP * GATE_HEIGHT
	bar.basis = Basis.looking_at(spec.tangent_at(at), Vector3.UP)
	gate.add_child(bar)
	return gate


func _cylinder(top: float, bottom: float, height: float) -> CylinderMesh:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = top
	mesh.bottom_radius = bottom
	mesh.height = height
	mesh.radial_segments = 8
	return mesh


func _multimesh(mesh: Mesh, colour: Color) -> MultiMesh:
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mesh.surface_set_material(0, _flat(colour))
	multimesh.mesh = mesh
	return multimesh


func _multimesh_instance(multimesh: MultiMesh) -> MultiMeshInstance3D:
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.multimesh = multimesh
	return instance


func _vertex_colour_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	return material


func _flat(colour: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = colour
	return material
