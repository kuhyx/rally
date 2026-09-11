extends GutTest
## Lookups along the finished stage: offsets, surfaces, finish, spawn.


func test_surface_at_position_matches_offset() -> void:
	var spec: StageSpec = StageSpec.new(5)
	var near_end: Vector3 = spec.point_at(spec.length() - 30.0)
	assert_eq(spec.surface_at(near_end), Surface.Kind.GRAVEL)
	assert_eq(spec.surface_at(spec.point_at(5.0)), Surface.Kind.TARMAC)


func test_off_road_is_grass() -> void:
	var spec: StageSpec = StageSpec.new(5)
	var at: float = 300.0
	var right: Vector3 = spec.tangent_at(at).cross(Vector3.UP).normalized()
	var edge: float = StageSpec.WIDTH * 0.5
	assert_eq(spec.surface_at(spec.point_at(at) + right * (edge - 0.5)), Surface.Kind.TARMAC)
	assert_eq(spec.surface_at(spec.point_at(at) + right * (edge + 1.0)), Surface.Kind.GRASS)
	assert_eq(spec.surface_at(spec.point_at(at) - right * (edge + 1.0)), Surface.Kind.GRASS)


func test_run_off_past_the_ends_is_still_road() -> void:
	var spec: StageSpec = StageSpec.new(5)
	var end: float = spec.length()
	var beyond: Vector3 = spec.point_at(end) + spec.tangent_at(end) * 40.0
	assert_eq(spec.surface_at(beyond), Surface.Kind.GRAVEL)
	var before: Vector3 = spec.point_at(0.0) - spec.tangent_at(0.0) * 40.0
	assert_eq(spec.surface_at(before), Surface.Kind.TARMAC)


func test_progress_at_point_on_curve() -> void:
	var spec: StageSpec = StageSpec.new(11)
	var offset: float = 800.0
	assert_almost_eq(spec.progress_at(spec.point_at(offset)), offset, 2.0)


func test_point_at_clamps_offset() -> void:
	var spec: StageSpec = StageSpec.new(11)
	assert_eq(spec.point_at(-100.0), spec.point_at(0.0))
	assert_eq(spec.point_at(spec.length() + 100.0), spec.point_at(spec.length()))


func test_tangent_is_unit_and_forward() -> void:
	var spec: StageSpec = StageSpec.new(2)
	var tangent: Vector3 = spec.tangent_at(500.0)
	assert_almost_eq(tangent.length(), 1.0, 0.001)
	assert_gt(tangent.z, 0.0)


func test_is_finished_near_end_only() -> void:
	var spec: StageSpec = StageSpec.new(2)
	assert_false(spec.is_finished(0.0))
	assert_false(spec.is_finished(spec.length() - StageSpec.FINISH_MARGIN - 1.0))
	assert_true(spec.is_finished(spec.length() - StageSpec.FINISH_MARGIN))


func test_start_transform_faces_along_road() -> void:
	var spec: StageSpec = StageSpec.new(2)
	var start: Transform3D = spec.start_transform()
	assert_eq(start.origin, spec.point_at(StageSpec.START_OFFSET))
	var forward: Vector3 = -start.basis.z
	assert_almost_eq(forward.dot(spec.tangent_at(StageSpec.START_OFFSET)), 1.0, 0.01)
