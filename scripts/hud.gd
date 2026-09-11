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
	_clock = _label(FONT_BIG, HORIZONTAL_ALIGNMENT_LEFT, Control.PRESET_TOP_LEFT)
	_best = _label(FONT_SMALL, HORIZONTAL_ALIGNMENT_RIGHT, Control.PRESET_TOP_RIGHT)
	_speed = _label(FONT_BIG, HORIZONTAL_ALIGNMENT_RIGHT, Control.PRESET_BOTTOM_RIGHT)
	_finish = _label(FONT_BIG, HORIZONTAL_ALIGNMENT_CENTER, Control.PRESET_CENTER)
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


## A label pinned to one corner (or the centre) that grows INTO the screen,
## so a right- or bottom-anchored label never hangs off the edge.
func _label(size: int, alignment: HorizontalAlignment, preset: Control.LayoutPreset) -> Label:
	var label: Label = Label.new()
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Palette.CREAM)
	label.add_theme_color_override("font_outline_color", Palette.INK)
	label.add_theme_constant_override("outline_size", 8)
	label.set_anchors_and_offsets_preset(preset, Control.PRESET_MODE_KEEP_SIZE, int(MARGIN))
	label.grow_horizontal = _grow(
		alignment == HORIZONTAL_ALIGNMENT_RIGHT, preset == Control.PRESET_CENTER
	)
	var bottom: bool = preset == Control.PRESET_BOTTOM_RIGHT
	label.grow_vertical = _grow(bottom, preset == Control.PRESET_CENTER)
	add_child(label)
	return label


func _grow(toward_begin: bool, both: bool) -> Control.GrowDirection:
	if both:
		return Control.GROW_DIRECTION_BOTH
	return Control.GROW_DIRECTION_BEGIN if toward_begin else Control.GROW_DIRECTION_END
