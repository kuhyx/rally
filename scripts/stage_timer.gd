class_name StageTimer
extends RefCounted
## Stage clock: starts on the first call to `start`, records a split every
## SPLIT_EVERY metres, and freezes at the finish line.

enum State { IDLE, RUNNING, FINISHED }

const SPLIT_EVERY: float = 500.0

var state: State = State.IDLE
var elapsed: float = 0.0
var splits: Array[float] = []
var _next_split: float = SPLIT_EVERY


func start() -> void:
	if state == State.IDLE:
		state = State.RUNNING


func tick(delta: float, progress: float, finished: bool) -> void:
	if state != State.RUNNING:
		return
	elapsed += delta
	while progress >= _next_split:
		splits.push_back(elapsed)
		_next_split += SPLIT_EVERY
	if finished:
		state = State.FINISHED


func is_finished() -> bool:
	return state == State.FINISHED


func is_running() -> bool:
	return state == State.RUNNING


static func format_time(seconds: float) -> String:
	var minutes: int = floori(seconds / 60.0)
	var rest: float = seconds - minutes * 60.0
	return "%d:%06.3f" % [minutes, rest]


## A best time of 0 means "no time recorded yet".
static func is_best(candidate: float, previous: float) -> bool:
	return previous <= 0.0 or candidate < previous
