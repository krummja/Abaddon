extends Node

@onready var subviewport: SubViewport = $SubViewport

func _ready() -> void:
    pass

func _unhandled_input(event: InputEvent) -> void:
    subviewport.push_input(event)
    # if event is InputEventMouse:
    #     event.position -= position

