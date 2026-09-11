extends GutTest


func test_idle_until_started() -> void:
	var timer: StageTimer = StageTimer.new()
	timer.tick(1.0, 0.0, false)
	assert_eq(timer.elapsed, 0.0)
	assert_false(timer.is_running())
	assert_false(timer.is_finished())


func test_accumulates_while_running() -> void:
	var timer: StageTimer = StageTimer.new()
	timer.start()
	timer.tick(0.5, 10.0, false)
	timer.tick(0.25, 20.0, false)
	assert_almost_eq(timer.elapsed, 0.75, 0.0001)
	assert_true(timer.is_running())


func test_start_twice_is_harmless() -> void:
	var timer: StageTimer = StageTimer.new()
	timer.start()
	timer.tick(1.0, 0.0, false)
	timer.start()
	assert_eq(timer.elapsed, 1.0)


func test_records_split_per_500m() -> void:
	var timer: StageTimer = StageTimer.new()
	timer.start()
	timer.tick(10.0, 499.0, false)
	assert_eq(timer.splits.size(), 0)
	timer.tick(1.0, 500.0, false)
	assert_eq(timer.splits, [11.0])
	timer.tick(20.0, 1250.0, false)
	assert_eq(timer.splits, [11.0, 31.0])


func test_freezes_at_finish() -> void:
	var timer: StageTimer = StageTimer.new()
	timer.start()
	timer.tick(3.0, 100.0, true)
	timer.tick(3.0, 200.0, false)
	assert_eq(timer.elapsed, 3.0)
	assert_true(timer.is_finished())
	assert_false(timer.is_running())


func test_format_time() -> void:
	assert_eq(StageTimer.format_time(0.0), "0:00.000")
	assert_eq(StageTimer.format_time(83.456), "1:23.456")
	assert_eq(StageTimer.format_time(600.0), "10:00.000")


func test_is_best() -> void:
	assert_true(StageTimer.is_best(90.0, 0.0))
	assert_true(StageTimer.is_best(90.0, 91.0))
	assert_false(StageTimer.is_best(90.0, 89.0))
	assert_false(StageTimer.is_best(90.0, 90.0))
