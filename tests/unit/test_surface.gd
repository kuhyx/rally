extends GutTest


func test_gravel_has_less_grip_than_tarmac() -> void:
	assert_lt(Surface.grip(Surface.Kind.GRAVEL), Surface.grip(Surface.Kind.TARMAC))


func test_gravel_has_more_drag_than_tarmac() -> void:
	assert_gt(Surface.drag(Surface.Kind.GRAVEL), Surface.drag(Surface.Kind.TARMAC))


func test_every_kind_has_colour_and_name() -> void:
	for kind: Surface.Kind in Surface.Kind.values():
		assert_ne(Surface.color(kind), Color.BLACK)
		assert_ne(Surface.display_name(kind), "")


func test_names_are_distinct() -> void:
	assert_ne(Surface.display_name(Surface.Kind.TARMAC), Surface.display_name(Surface.Kind.GRAVEL))
