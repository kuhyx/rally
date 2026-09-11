extends GutTest


func test_defaults_when_no_args() -> void:
	var options: LaunchOptions = LaunchOptions.parse(PackedStringArray())
	assert_eq(options.seed_value, LaunchOptions.DEFAULT_SEED)
	assert_false(options.autodrive)
	assert_false(options.quit_on_finish)


func test_parses_every_flag() -> void:
	var args: PackedStringArray = PackedStringArray(
		["--seed=42", "--autodrive", "--quit-on-finish"]
	)
	var options: LaunchOptions = LaunchOptions.parse(args)
	assert_eq(options.seed_value, 42)
	assert_true(options.autodrive)
	assert_true(options.quit_on_finish)


func test_negative_seed_is_valid() -> void:
	var options: LaunchOptions = LaunchOptions.parse(PackedStringArray(["--seed=-7"]))
	assert_eq(options.seed_value, -7)


func test_non_integer_seed_keeps_default() -> void:
	var options: LaunchOptions = LaunchOptions.parse(PackedStringArray(["--seed=abc"]))
	assert_eq(options.seed_value, LaunchOptions.DEFAULT_SEED)


func test_unknown_flags_are_ignored() -> void:
	var options: LaunchOptions = LaunchOptions.parse(PackedStringArray(["--bogus", "x"]))
	assert_eq(options.seed_value, LaunchOptions.DEFAULT_SEED)
	assert_false(options.autodrive)
