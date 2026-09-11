extends GutTest
## Black-box run of the real game: a second Godot process drives the stage
## with --fixed-fps, so 78 simulated seconds take about two real ones. Two
## runs of one seed must produce the same finish time (determinism), and a
## second seed must also finish (the autodriver is not tuned to one stage).

const SEEDS: Array[int] = [42, 7]
const MAX_STAGE_SECONDS: float = 150.0
const WALL_TIMEOUT_MS: int = 60_000
const POLL_MS: int = 200


func test_same_seed_is_deterministic() -> void:
	var first: float = _finish_time(SEEDS[0])
	var second: float = _finish_time(SEEDS[0])
	assert_gt(first, 0.0, "run must reach the finish")
	assert_eq(first, second, "identical seed must give identical finish time")


func test_other_seed_finishes() -> void:
	var elapsed: float = _finish_time(SEEDS[1])
	assert_between(elapsed, 30.0, MAX_STAGE_SECONDS)


## Runs the game as a child process with a wall-clock cap: a build that
## cannot compile never prints FINISH, and OS.execute would wait forever.
func _finish_time(seed_value: int) -> float:
	var stdout_path: String = "user://autodrive_%d.log" % seed_value
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
	var shell: String = (
		"%s %s > %s 2>&1"
		% [OS.get_executable_path(), " ".join(args), ProjectSettings.globalize_path(stdout_path)]
	)
	var pid: int = OS.create_process("/bin/sh", PackedStringArray(["-c", shell]))
	assert_gt(pid, 0, "game process must start")
	var waited: int = 0
	while OS.is_process_running(pid) and waited < WALL_TIMEOUT_MS:
		OS.delay_msec(POLL_MS)
		waited += POLL_MS
	if OS.is_process_running(pid):
		var killed: Error = OS.kill(pid)
		fail_test(
			"game did not finish within %d ms (kill: %s)" % [WALL_TIMEOUT_MS, error_string(killed)]
		)
		return 0.0
	assert_eq(OS.get_process_exit_code(pid), 0, "game process exit code")
	for line: String in FileAccess.get_file_as_string(stdout_path).split("\n"):
		if line.begins_with("FINISH "):
			return line.trim_prefix("FINISH ").to_float()
	return 0.0
