extends Node

@onready var subject_view := $SubjectView
@onready var system_view := $SystemView
@onready var galaxy_view := $GalaxyView

func _ready():
    Engine.time_scale = 1.0
