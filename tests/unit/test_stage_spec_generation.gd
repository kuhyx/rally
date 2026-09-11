extends GutTest
## Seed -> stage: determinism, shape bounds, surface layout.


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
