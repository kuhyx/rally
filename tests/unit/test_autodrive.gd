extends GutTest

const FORWARD: Vector3 = Vector3(0.0, 0.0, -1.0)


func test_steer_angle_sign_right_is_positive() -> void:
	var right: Vector3 = Vector3(10.0, 0.0, -10.0)
	var left: Vector3 = Vector3(-10.0, 0.0, -10.0)
	assert_gt(Autodrive.steer_angle(Vector3.ZERO, FORWARD, right), 0.0)
	assert_lt(Autodrive.steer_angle(Vector3.ZERO, FORWARD, left), 0.0)
	assert_almost_eq(Autodrive.steer_angle(Vector3.ZERO, FORWARD, right), PI / 4.0, 0.001)


func test_steer_angle_ignores_height_and_degenerate_input() -> void:
	assert_eq(Autodrive.steer_angle(Vector3.ZERO, FORWARD, Vector3(0.0, 50.0, -10.0)), 0.0)
	assert_eq(Autodrive.steer_angle(Vector3.ZERO, FORWARD, Vector3.ZERO), 0.0)
	assert_eq(Autodrive.steer_angle(Vector3.ZERO, Vector3.UP, Vector3(1.0, 0.0, 0.0)), 0.0)


func test_full_throttle_when_slow_and_straight() -> void:
	var spec: StageSpec = StageSpec.new(42)
	var driver: Autodrive = Autodrive.new(spec)
	var input: CarInput = driver.control(spec.point_at(20.0), spec.tangent_at(20.0), 5.0)
	assert_eq(input.throttle, 1.0)
	assert_eq(input.brake, 0.0)
	assert_false(input.handbrake)


func test_brakes_above_top_speed() -> void:
	var spec: StageSpec = StageSpec.new(42)
	var driver: Autodrive = Autodrive.new(spec)
	var input: CarInput = driver.control(
		spec.point_at(20.0), spec.tangent_at(20.0), Autodrive.TOP_SPEED + 1.0
	)
	assert_eq(input.throttle, 0.0)
	assert_gt(input.brake, 0.0)


func test_brakes_for_a_bend_when_fast() -> void:
	var spec: StageSpec = StageSpec.new(42)
	var driver: Autodrive = Autodrive.new(spec)
	# Facing 90 degrees off the road at a speed that is fine on a straight.
	var sideways: Vector3 = spec.tangent_at(20.0).cross(Vector3.UP)
	var input: CarInput = driver.control(spec.point_at(20.0), sideways, Autodrive.TOP_SPEED * 0.8)
	assert_gt(input.brake, 0.0)
	assert_eq(absf(input.steer), 1.0)


func test_steers_back_toward_road_when_offset() -> void:
	var spec: StageSpec = StageSpec.new(42)
	var driver: Autodrive = Autodrive.new(spec)
	var tangent: Vector3 = spec.tangent_at(100.0)
	var right: Vector3 = tangent.cross(Vector3.UP).normalized()
	var off_right: CarInput = driver.control(spec.point_at(100.0) + right * 4.0, tangent, 10.0)
	var off_left: CarInput = driver.control(spec.point_at(100.0) - right * 4.0, tangent, 10.0)
	assert_lt(off_right.steer, 0.0)
	assert_gt(off_left.steer, 0.0)
