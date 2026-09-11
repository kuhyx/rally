extends GutTest


func test_same_seed_identical_stage() -> void:
	var a: StageSpec = StageSpec.new(42)
	var b: StageSpec = StageSpec.new(42)
	assert_eq(a.control_points(), b.control_points())
	assert_eq(a.length(), b.length())


func test_different_seed_different_stage() -> void:
	var a: StageSpec = StageSpec.new(1)
	var b: StageSpec = StageSpec.new(2)
	assert_ne(a.control_points(), b.control_points())


func test_length_is_about_stage_length() -> void:
	var spec: StageSpec = StageSpec.new(7)
	assert_between(spec.length(), StageSpec.STAGE_LENGTH * 0.95, StageSpec.STAGE_LENGTH * 1.15)


func test_z_is_monotonic_so_road_never_crosses() -> void:
	for seed_value: int in range(1, 6):
		var points: Array[Vector3] = StageSpec.new(seed_value).control_points()
		for i: int in range(1, points.size()):
			assert_gt(points[i].z, points[i - 1].z, "seed %d point %d" % [seed_value, i])


func test_elevation_stays_bounded() -> void:
	for point: Vector3 in StageSpec.new(3).control_points():
		assert_between(point.y, -StageSpec.CLIMB_LIMIT, StageSpec.CLIMB_LIMIT)


func test_surface_starts_tarmac_ends_gravel() -> void:
	var spec: StageSpec = StageSpec.new(5)
	assert_eq(spec.surface_at_offset(0.0), Surface.Kind.TARMAC)
	assert_eq(spec.surface_at_offset(spec.length()), Surface.Kind.GRAVEL)
	assert_eq(spec.surface_at_offset(-50.0), Surface.Kind.TARMAC)
	assert_eq(spec.surface_at_offset(spec.length() * 5.0), Surface.Kind.GRAVEL)


func test_surface_at_position_matches_offset() -> void:
	var spec: StageSpec = StageSpec.new(5)
	var near_end: Vector3 = spec.point_at(spec.length() - 30.0)
	assert_eq(spec.surface_at(near_end), Surface.Kind.GRAVEL)
	assert_eq(spec.surface_at(spec.point_at(5.0)), Surface.Kind.TARMAC)


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
