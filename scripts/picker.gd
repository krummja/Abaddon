extends PanelContainer

@onready var item = $MarginContainer/HBoxContainer/ColorRect

func _ready():
    item.gui_input.connect(_on_item_input)

func _on_item_input(event: InputEvent):
    if event is InputEventMouseButton:
        var mouse_pos = get_viewport().get_mouse_position()
        print(mouse_pos)
