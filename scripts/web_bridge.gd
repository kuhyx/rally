class_name WebBridge
## The web build's only JavaScript surface: `window.__gameReady` (set once the
## first frame is up, timed by tests/web_smoke.py) and `window.__rally`, a
## small telemetry object the smoke test reads to prove the sim runs in the
## browser. No-ops on every other platform.


static func mark_ready() -> void:
	_eval("window.__gameReady = performance.now();")


static func report(progress: float, speed_kmh: float, finished: bool) -> void:
	_eval(
		(
			"window.__rally = {progress: %f, speed: %f, finished: %s};"
			% [progress, speed_kmh, "true" if finished else "false"]
		)
	)


static func _eval(code: String) -> void:
	if not OS.has_feature("web"):
		return
	# Every snippet ends in `true` so a null result means the JS threw.
	var evaluated: Variant = JavaScriptBridge.eval(code + " true;")
	if evaluated != true:
		push_warning("JavaScript failed: %s" % code)
