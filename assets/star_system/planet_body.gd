@icon("res://textures/planet_icon.svg")

class_name PlanetBody
extends SystemBody

@export var color: Color
@export var radius: float

var visual: BodyVisual

func _ready() -> void:
    visual = BodyVisual.new()
    visual.color = color
    visual.radius = radius
    add_child(visual)

func _process(_delta: float) -> void:
    pass
