class_name GridController
extends Node3D

@export var debug: bool = false
@export var enabled: bool = true

@export var grid_section: PackedScene
@export var target: Node3D
@export var section_scale: int = 100
@export_range(0.1, 15.0, 0.1) var unit_size: float = 5.0

var _directions: Array[Vector2] = [
    Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
    Vector2(-1,  0), Vector2(0,  0), Vector2(1,  0),
    Vector2(-1,  1), Vector2(0,  1), Vector2(1,  1),
]

var _last_id: int = 0
var _enter_call_id: int = 0
var _exit_call_id: int = 0

func _ready():
    if enabled:
        populate_sections()

func _process(_delta: float) -> void:
    if not enabled:
        return

    for section in get_tree().get_nodes_in_group("sections"):
        section.update_shader(
            target.global_position,
            unit_size,
        )

func _physics_process(_delta: float) -> void:
    global_position.y = target.global_position.y
    if debug:
        _draw_debug()

func populate_sections() -> void:
    if debug:
        print("[%d][%d] Populating Sections" % [_enter_call_id, _exit_call_id])

    for direction in _directions:
        create_section(direction)

func destroy_sections() -> void:
    for section in get_tree().get_nodes_in_group("sections"):
        destroy_section(section)

func create_section(direction: Vector2) -> GridSection:
    var section: GridSection = grid_section.instantiate()
    section.name = "GridSection-%04d" % _last_id
    _last_id += 1

    section.set_size(section_scale)

    section.position = (
        Vector3(
            target.global_position.x + direction.x * section_scale,
            0,
            target.global_position.z + direction.y * section_scale,
        )
        .snapped(Vector3(section_scale, 0, section_scale))
    )

    call_deferred("add_child", section)

    section.section_entered.connect(_section_entered)
    section.section_exited.connect(_section_exited)
    section.section_destroyed.connect(_section_destroyed)

    if debug:
        section.debug = true

    return section

func destroy_section(section: GridSection) -> void:
    section.destroy()

func _section_entered(_section: GridSection) -> void:
    if debug:
        print("[%d][%d] Entered %s" % [_enter_call_id, _exit_call_id, _section.name])
        _enter_call_id += 1

func _section_exited(_section: GridSection) -> void:
    if debug:
        print("[%d][%d] *** Exited %s" % [_enter_call_id, _exit_call_id, _section.name])
        _exit_call_id += 1
    destroy_sections()
    populate_sections()

func _section_destroyed(_section: GridSection) -> void:
    if debug:
        print("[%d][%d] %s Destroyed" % [_enter_call_id, _exit_call_id, _section.name])

func _draw_debug() -> void:
    DebugDraw3D.draw_position(global_transform)
