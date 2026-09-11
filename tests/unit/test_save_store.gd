extends GutTest

const SCRATCH: String = "user://test_best_times.json"


func before_each() -> void:
	SaveStore.path = SCRATCH
	_remove_scratch()


func after_all() -> void:
	_remove_scratch()
	SaveStore.path = "user://best_times.json"


func test_missing_file_reads_zero() -> void:
	assert_eq(SaveStore.read_best(1), 0.0)


func test_round_trip_per_seed() -> void:
	SaveStore.write_best(1, 95.5)
	SaveStore.write_best(2, 80.25)
	assert_eq(SaveStore.read_best(1), 95.5)
	assert_eq(SaveStore.read_best(2), 80.25)
	assert_eq(SaveStore.read_best(3), 0.0)


func test_overwrite_keeps_other_seeds() -> void:
	SaveStore.write_best(1, 95.5)
	SaveStore.write_best(2, 80.25)
	SaveStore.write_best(1, 70.0)
	assert_eq(SaveStore.read_best(1), 70.0)
	assert_eq(SaveStore.read_best(2), 80.25)


func test_corrupt_file_reads_zero() -> void:
	var file: FileAccess = FileAccess.open(SCRATCH, FileAccess.WRITE)
	assert_true(file.store_string("not json"))
	file.close()
	assert_eq(SaveStore.read_best(1), 0.0)


func test_wrong_value_type_reads_zero() -> void:
	var file: FileAccess = FileAccess.open(SCRATCH, FileAccess.WRITE)
	assert_true(file.store_string('{"1": "fast"}'))
	file.close()
	assert_eq(SaveStore.read_best(1), 0.0)


func _remove_scratch() -> void:
	if FileAccess.file_exists(SCRATCH):
		var result: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(SCRATCH))
		assert_eq(result, OK)
