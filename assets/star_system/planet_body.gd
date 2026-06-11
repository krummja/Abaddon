@icon("res://textures/planet_icon.svg")

class_name PlanetBody
extends SystemBody

@export var color: Color
@export var radius: float

var body_visual: BodyVisual
var orbit_visual: OrbitVisual
var plane_visual: PlaneVisual
var selectable: Selectable

func setup() -> void:
    body_visual = BodyVisual.new(self, color, radius)
    add_child(body_visual)

    orbit_visual = OrbitVisual.new(self)
    add_child(orbit_visual)

    plane_visual = PlaneVisual.new()
    add_child(plane_visual)

    selectable = Selectable.new()
    add_child(selectable)

    Debug.debug("PlanetBody %s" % name)
