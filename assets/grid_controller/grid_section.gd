class_name GridSection
extends MeshInstance3D

signal section_entered
signal section_exited

@export var debug: bool = false

var _mesh: PlaneMesh:
    get:
        return mesh

var _size: int = 100
var _debug_color: Color = Color(1, 0, 0, 1)

@onready var boundary := $Area3D

func _ready():
    boundary.connect("area_entered", _on_area_entered)
    boundary.connect("area_exited", _on_area_exited)

func _physics_process(_delta: float) -> void:
    if debug:
        _draw_debug()

func update_shader(x: float, y: float, z: float) -> void:
    set_instance_shader_parameter("centerOffset", Vector3(x, y, z))

func set_size(size: int) -> void:
    _size = size
    _mesh.size.x = size
    _mesh.size.y = size

func _draw_debug() -> void:
    DebugDraw3D.draw_box(
        global_position,
        transform.basis.get_rotation_quaternion(),
        Vector3(_mesh.size.x, 1, _mesh.size.y),
        _debug_color,
        true,
    )

func _on_area_entered(_area: Area3D) -> void:
    section_entered.emit()
    _debug_color = Color(0, 1, 0, 1)

func _on_area_exited(_area: Area3D) -> void:
    section_exited.emit()
    _debug_color = Color(1, 0, 0, 1)
