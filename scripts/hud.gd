class_name Hud
extends CanvasLayer
## Stage clock, speed, surface, best time, and the finish card. Text only;
## every colour is from Palette.

const FONT_BIG: int = 64
const FONT_SMALL: int = 32
const MARGIN: float = 32.0

var _clock: Label
var _speed: Label
var _best: Label
var _finish: Label


func _ready() -> void:
	_clock = _label(FONT_BIG, HORIZONTAL_ALIGNMENT_LEFT)
	_clock.set_anchors_and_offsets_preset(
		Control.PRESET_TOP_LEFT, Control.PRESET_MODE_KEEP_SIZE, int(MARGIN)
	)
	_best = _label(FONT_SMALL, HORIZONTAL_ALIGNMENT_RIGHT)
	_best.set_anchors_and_offsets_preset(
		Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_KEEP_SIZE, int(MARGIN)
	)
	_speed = _label(FONT_BIG, HORIZONTAL_ALIGNMENT_RIGHT)
	_speed.set_anchors_and_offsets_preset(
		Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_KEEP_SIZE, int(MARGIN)
	)
	_finish = _label(FONT_BIG, HORIZONTAL_ALIGNMENT_CENTER)
	_finish.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_finish.visible = false


func show_best(best: float) -> void:
	_best.text = "best  " + StageTimer.format_time(best) if best > 0.0 else "no best yet"


func update(timer: StageTimer, speed_kmh: float, surface: Surface.Kind) -> void:
	_clock.text = StageTimer.format_time(timer.elapsed)
	_speed.text = "%d km/h\n%s" % [roundi(speed_kmh), Surface.display_name(surface)]


func show_finish(elapsed: float, new_best: bool) -> void:
	var verdict: String = "NEW BEST" if new_best else "finished"
	_finish.text = "%s\n%s\nR to restart" % [verdict, StageTimer.format_time(elapsed)]
	_finish.visible = true


func _label(size: int, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Palette.CREAM)
	label.add_theme_color_override("font_outline_color", Palette.INK)
	label.add_theme_constant_override("outline_size", 8)
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(label)
	return label
