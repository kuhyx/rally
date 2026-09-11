class_name Surface
## Road surfaces and how each one changes the car. Grip feeds
## VehicleWheel3D.wheel_friction_slip; drag is a speed-proportional brake.

enum Kind { TARMAC, GRAVEL }

const GRIP: Dictionary = {Kind.TARMAC: 10.5, Kind.GRAVEL: 4.5}
const DRAG: Dictionary = {Kind.TARMAC: 0.0, Kind.GRAVEL: 0.35}
const COLOR: Dictionary = {Kind.TARMAC: Palette.TARMAC, Kind.GRAVEL: Palette.GRAVEL}
const NAME: Dictionary = {Kind.TARMAC: "tarmac", Kind.GRAVEL: "gravel"}


static func grip(kind: Kind) -> float:
	return GRIP[kind]


static func drag(kind: Kind) -> float:
	return DRAG[kind]


static func color(kind: Kind) -> Color:
	return COLOR[kind]


static func display_name(kind: Kind) -> String:
	return NAME[kind]
