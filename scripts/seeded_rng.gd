class_name SeededRng
extends RefCounted
## Deterministic random source. Same seed, same sequence, on every platform.

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(seed_value: int) -> void:
	_rng.seed = seed_value


func randf_range(low: float, high: float) -> float:
	return _rng.randf_range(low, high)


func randi_range(low: int, high: int) -> int:
	return _rng.randi_range(low, high)
