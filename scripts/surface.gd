class_name Surface
## Road surfaces and how each one changes the car. Grip feeds
## VehicleWheel3D.wheel_friction_slip; drag is a speed-proportional brake.

## GRASS is never laid on the stage; it is what the car finds off the road.
enum Kind { TARMAC, GRAVEL, GRASS }

const GRIP: Dictionary = {Kind.TARMAC: 10.5, Kind.GRAVEL: 4.5, Kind.GRASS: 3.0}
const DRAG: Dictionary = {Kind.TARMAC: 0.0, Kind.GRAVEL: 0.35, Kind.GRASS: 0.8}
const COLOR: Dictionary = {
	Kind.TARMAC: Palette.TARMAC, Kind.GRAVEL: Palette.GRAVEL, Kind.GRASS: Palette.GRASS
}
const NAME: Dictionary = {Kind.TARMAC: "tarmac", Kind.GRAVEL: "gravel", Kind.GRASS: "grass"}


static func grip(kind: Kind) -> float:
	return GRIP[kind]


static func drag(kind: Kind) -> float:
	return DRAG[kind]


static func color(kind: Kind) -> Color:
	return COLOR[kind]


static func display_name(kind: Kind) -> String:
	return NAME[kind]
