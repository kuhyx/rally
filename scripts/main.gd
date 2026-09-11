class_name Main
extends Node3D
## Wires the stage, car, camera and timer together and owns the frame loop.

const SPAWN_LIFT: float = 1.0
const FALL_RESET_Y: float = -60.0

var options: LaunchOptions
var spec: StageSpec
var timer: StageTimer = StageTimer.new()
var car: Car
var hud: Hud
var best: float = 0.0
var _autodrive: Autodrive
var _finished_handled: bool = false
var _last_report: int = -1


func _ready() -> void:
	options = LaunchOptions.parse(OS.get_cmdline_user_args())
	spec = StageSpec.new(options.seed_value)
	_autodrive = Autodrive.new(spec)
	var builder: StageBuilder = StageBuilder.new()
	add_child(builder)
	builder.build(spec, options.seed_value)
	_add_light()
	car = Car.new()
	car.spec = spec
	add_child(car)
	_place_car_at_start()
	var cam: ChaseCam = ChaseCam.new()
	cam.target = car
	add_child(cam)
	cam.snap()
	hud = Hud.new()
	add_child(hud)
	best = SaveStore.read_best(options.seed_value)
	hud.show_best(best)
	# Deferred so the first frame has actually been drawn.
	WebBridge.mark_ready.call_deferred()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		_restart()
	car.control = _read_control()
	if car.control.throttle > 0.0:
		timer.start()
	var progress: float = spec.progress_at(car.global_position)
	timer.tick(delta, progress, spec.is_finished(progress))
	if car.global_position.y < FALL_RESET_Y:
		_place_car_at_start()
	hud.update(timer, car.speed_kmh(), spec.surface_at(car.global_position))
	WebBridge.report(progress, car.speed_kmh(), timer.is_finished())
	if options.autodrive:
		_report(progress)
	if timer.is_finished() and not _finished_handled:
		_on_finished()


func _read_control() -> CarInput:
	if options.autodrive:
		return _autodrive.control(car.global_position, car.forward(), car.linear_velocity.length())
	return CarInput.from_actions(Input.get_action_strength)


func _on_finished() -> void:
	_finished_handled = true
	# The autodriver is not the player: its times never become the best.
	var new_best: bool = not options.autodrive and StageTimer.is_best(timer.elapsed, best)
	if new_best:
		SaveStore.write_best(options.seed_value, timer.elapsed)
	hud.show_finish(timer.elapsed, new_best)
	if options.quit_on_finish:
		print("FINISH %.3f" % timer.elapsed)
		get_tree().quit()


## One telemetry line per second so a headless autodrive run is observable.
func _report(progress: float) -> void:
	var second: int = floori(timer.elapsed)
	if second != _last_report:
		_last_report = second
		print(
			"T %d P %.0f V %.0f Y %.1f" % [second, progress, car.speed_kmh(), car.global_position.y]
		)


func _restart() -> void:
	var result: Error = get_tree().reload_current_scene()
	if result != OK:
		push_warning("Could not restart: %s" % error_string(result))


func _place_car_at_start() -> void:
	var start: Transform3D = spec.start_transform()
	start.origin += Vector3.UP * SPAWN_LIFT
	car.global_transform = start
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO


func _add_light() -> void:
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50.0, 30.0, 0.0)
	sun.shadow_enabled = true
	add_child(sun)
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Palette.SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Palette.CREAM
	env.ambient_light_energy = 0.6
	var world: WorldEnvironment = WorldEnvironment.new()
	world.environment = env
	add_child(world)
