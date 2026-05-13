class_name GridController
extends Node3D

@export var debug: bool = false

@export var grid_section: PackedScene
@export var target: Node3D
@export var section_scale: int = 100

var _directions: Array[Vector2] = [
    Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
    Vector2(-1,  0), Vector2(0,  0), Vector2(1,  0),
    Vector2(-1,  1), Vector2(0,  1), Vector2(1,  1),
]

var _sections: Array[GridSection] = []

var _center_section: GridSection

func _ready():
    populate_sections()

func _process(_delta: float) -> void:
    for section in _sections:
        section.update_shader(
            target.global_position.x,
            target.global_position.y,
            target.global_position.z,
        )

func _physics_process(_delta: float) -> void:
    position.y = target.global_position.y

    if debug:
        _draw_debug()

func populate_sections() -> void:
    for direction in _directions:
        var section = create_section(direction)
        push_section(section)
        add_child(section)

func create_section(direction: Vector2) -> GridSection:
    var section: GridSection = grid_section.instantiate()
    section.set_size(section_scale)
    section.position = Vector3(direction.x * section_scale, 0, direction.y * section_scale)

    if debug:
        section.debug = true

    return section

func destroy_section(section: GridSection) -> void:
    remove_child(section)
    section.queue_free()

func push_section(section: GridSection) -> void:
    _sections.push_back(section)

func _draw_debug() -> void:
    DebugDraw3D.draw_position(global_transform)
