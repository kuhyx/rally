extends GutTest


func test_colours_are_distinct() -> void:
	var colours: Array[Color] = [
		Palette.SKY,
		Palette.GRASS,
		Palette.TARMAC,
		Palette.GRAVEL,
		Palette.CAR,
		Palette.TREE,
		Palette.TRUNK,
		Palette.GATE,
		Palette.INK,
		Palette.CREAM,
	]
	for i: int in range(colours.size()):
		for j: int in range(i + 1, colours.size()):
			assert_ne(colours[i], colours[j], "colour %d equals colour %d" % [i, j])


func test_hud_ink_and_cream_contrast() -> void:
	assert_gt(Palette.CREAM.get_luminance() - Palette.INK.get_luminance(), 0.7)
