extends GutTest


func _reader(values: Dictionary) -> Callable:
	return func(action: String) -> float: return values.get(action, 0.0)


func test_reads_every_action() -> void:
	var input: CarInput = CarInput.from_actions(
		_reader({"throttle": 0.8, "brake": 0.3, "steer_right": 1.0, "handbrake": 1.0})
	)
	assert_almost_eq(input.throttle, 0.8, 0.0001)
	assert_almost_eq(input.brake, 0.3, 0.0001)
	assert_eq(input.steer, 1.0)
	assert_true(input.handbrake)


func test_steer_left_is_negative_and_opposites_cancel() -> void:
	assert_eq(CarInput.from_actions(_reader({"steer_left": 1.0})).steer, -1.0)
	assert_eq(CarInput.from_actions(_reader({"steer_left": 1.0, "steer_right": 1.0})).steer, 0.0)


func test_strengths_are_clamped() -> void:
	var input: CarInput = CarInput.from_actions(_reader({"throttle": 5.0, "brake": -2.0}))
	assert_eq(input.throttle, 1.0)
	assert_eq(input.brake, 0.0)


func test_handbrake_threshold() -> void:
	assert_false(CarInput.from_actions(_reader({"handbrake": 0.4})).handbrake)
	assert_true(CarInput.from_actions(_reader({"handbrake": 0.6})).handbrake)


func test_smoothed_steer_moves_toward_target_at_rate() -> void:
	var step: float = CarInput.smoothed_steer(0.0, 1.0, 0.1)
	assert_almost_eq(step, CarInput.STEER_RATE * 0.1, 0.0001)
	assert_eq(CarInput.smoothed_steer(0.9, 1.0, 1.0), 1.0)
	assert_eq(CarInput.smoothed_steer(0.5, -1.0, 10.0), -1.0)
