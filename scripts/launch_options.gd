class_name LaunchOptions
extends RefCounted
## Command-line flags after `--`: `--seed=N`, `--autodrive`, `--quit-on-finish`.
## Parsed from a plain string array so the parser is testable without an OS.

const DEFAULT_SEED: int = 1
const SEED_PREFIX: String = "--seed="

var seed_value: int = DEFAULT_SEED
var autodrive: bool = false
var quit_on_finish: bool = false


static func parse(args: PackedStringArray) -> LaunchOptions:
	var options: LaunchOptions = LaunchOptions.new()
	for arg: String in args:
		if arg.begins_with(SEED_PREFIX):
			var raw: String = arg.trim_prefix(SEED_PREFIX)
			if raw.is_valid_int():
				options.seed_value = raw.to_int()
		elif arg == "--autodrive":
			options.autodrive = true
		elif arg == "--quit-on-finish":
			options.quit_on_finish = true
	return options
