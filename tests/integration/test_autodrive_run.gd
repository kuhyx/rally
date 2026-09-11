extends GutTest
## Black-box run of the real game: a second Godot process drives the stage
## with --fixed-fps, so 78 simulated seconds take about two real ones. Two
## runs of one seed must produce the same finish time (determinism), and a
## second seed must also finish (the autodriver is not tuned to one stage).

const SEEDS: Array[int] = [42, 7]
const MAX_STAGE_SECONDS: float = 150.0


func test_same_seed_is_deterministic() -> void:
	var first: float = _finish_time(SEEDS[0])
	var second: float = _finish_time(SEEDS[0])
	assert_gt(first, 0.0, "run must reach the finish")
	assert_eq(first, second, "identical seed must give identical finish time")


func test_other_seed_finishes() -> void:
	var elapsed: float = _finish_time(SEEDS[1])
	assert_between(elapsed, 30.0, MAX_STAGE_SECONDS)


func _finish_time(seed_value: int) -> float:
	var output: Array = []
	var args: PackedStringArray = PackedStringArray(
		[
			"--headless",
			"--fixed-fps",
			"60",
			"--path",
			ProjectSettings.globalize_path("res://"),
			"--",
			"--seed=%d" % seed_value,
			"--autodrive",
			"--quit-on-finish",
		]
	)
	var code: int = OS.execute(OS.get_executable_path(), args, output, true)
	assert_eq(code, 0, "game process exit code")
	for line: String in "".join(output).split("\n"):
		if line.begins_with("FINISH "):
			return line.trim_prefix("FINISH ").to_float()
	return 0.0
