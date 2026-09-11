extends GutTest


func test_same_seed_same_sequence() -> void:
	var a: SeededRng = SeededRng.new(123)
	var b: SeededRng = SeededRng.new(123)
	for _i: int in range(20):
		assert_eq(a.randf_range(-1.0, 1.0), b.randf_range(-1.0, 1.0))
		assert_eq(a.randi_range(0, 1000), b.randi_range(0, 1000))


func test_different_seed_different_sequence() -> void:
	var a: SeededRng = SeededRng.new(1)
	var b: SeededRng = SeededRng.new(2)
	var same: int = 0
	for _i: int in range(10):
		if a.randi_range(0, 1000000) == b.randi_range(0, 1000000):
			same += 1
	assert_lt(same, 10)


func test_values_stay_in_range() -> void:
	var rng: SeededRng = SeededRng.new(9)
	for _i: int in range(200):
		assert_between(rng.randf_range(2.0, 3.0), 2.0, 3.0)
		assert_between(rng.randi_range(-5, 5), -5, 5)
