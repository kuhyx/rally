class_name SaveStore
## Best time per stage seed in a JSON file. Knows nothing else about the game.
## `path` is a static so tests can point it at a scratch file.

static var path: String = "user://best_times.json"


static func read_best(seed_value: int) -> float:
	var data: Dictionary = _read()
	var key: String = str(seed_value)
	if not data.has(key):
		return 0.0
	var value: Variant = data[key]
	if value is float:
		return value
	return 0.0


static func write_best(seed_value: int, seconds: float) -> void:
	var data: Dictionary = _read()
	data[str(seed_value)] = seconds
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return
	if not file.store_string(JSON.stringify(data)):
		push_warning("Could not write %s" % path)


static func _read() -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	# JSON.parse (not parse_string) reports a bad file as a return code instead
	# of an engine error, so a corrupt save is a warning, not a crash report.
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) == OK and json.data is Dictionary:
		return json.data
	push_warning("Ignoring corrupt save file at %s" % path)
	return {}
