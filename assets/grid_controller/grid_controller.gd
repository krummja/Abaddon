extends Node3D
class_name GridController

@export var grid_section: PackedScene
@export var target_position: Node3D
@export var section_scale: int = 50

var _sections: Array[Node3D] = []

var _half_scale = section_scale / 2

# func _ready():
#     var section: Node3D = grid_section.instantiate()
#     var width = section.scale.x
#     var height = section.scale.y

#     add_child(section)
#     section.position = Vector3(-(width / 2), 0, -(height / 2))

func _process(delta):
    pass

func _populate_sections() -> void:
    for _i in range(0, 9):
        var section = grid_section.instantiate()
        _sections.push_back(section)
        section.position = Vector3.ONE
