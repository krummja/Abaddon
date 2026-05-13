extends Node3D
class_name GridController

@export var grid_section: PackedScene
@export var target: Node3D
@export var section_scale: int = 50

var _directions: Array[Vector2] = [
    Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
    Vector2(-1,  0), Vector2(0,  0), Vector2(1,  0),
    Vector2(-1,  1), Vector2(0,  1), Vector2(1,  1),
]

var _sections: Array[Node3D] = []

var _half_scale = section_scale / 2

func _ready():
    _populate_sections()

func _process(delta):
    for section in _sections:
        (section as GridSection).update_shader(target.global_position.x, target.global_position.z)

func _populate_sections() -> void:
    for direction in _directions:
        var section: GridSection = grid_section.instantiate()
        section.size = section_scale
        section.position = Vector3(direction.x * section_scale, 0, direction.y * section_scale)
        add_child(section)
        _sections.push_back(section)
