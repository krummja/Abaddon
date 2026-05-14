class_name GridSection
extends MeshInstance3D

signal section_entered(section: GridSection)
signal section_exited(section: GridSection)
signal section_destroyed(section: GridSection)

@export var debug: bool = false

@onready var boundary := $Area3D

var _mesh: PlaneMesh:
    get:
        return mesh

var _size: int = 100
var _debug_color: Color = Color(1, 0, 0, 1)
var _collision_occurred: bool = false
var _exited: bool = false
var _destroying: bool = false

func _ready():
    add_to_group("sections")
    boundary.monitoring = false
    boundary.connect("area_entered", _boundary_entered)
    boundary.connect("area_exited", _boundary_exited)
    set_physics_process(true)
    boundary.monitoring = true

func _physics_process(_delta: float) -> void:
    if _exited and _collision_occurred:
        disable_boundary()
    _collision_occurred = false

    if debug:
        _draw_debug()

func update_shader(x: float, y: float, z: float) -> void:
    set_instance_shader_parameter("centerOffset", Vector3(x, y, z))

func set_size(size: int) -> void:
    _size = size
    _mesh.size.x = size
    _mesh.size.y = size

func enable_boundary() -> void:
    boundary.monitoring = true

func disable_boundary() -> void:
    # boundary.monitoring = false
    boundary.set_deferred("monitoring", false)

func destroy() -> void:
    _destroying = true

    disable_boundary()
    boundary.queue_free()
    remove_from_group("sections")
    queue_free()
    section_destroyed.emit(self)

func _draw_debug() -> void:
    DebugDraw3D.draw_box(
        global_position,
        transform.basis.get_rotation_quaternion(),
        Vector3(_mesh.size.x, 1, _mesh.size.y),
        _debug_color,
        true,
    )

func _boundary_entered(_area: Area3D) -> void:
    _exited = false
    _collision_occurred = true
    section_entered.emit(self)
    _debug_color = Color(0, 1, 0, 1)

func _boundary_exited(_area: Area3D) -> void:
    if _destroying:
        return

    _exited = true
    _collision_occurred = true
    section_exited.emit(self)
    _debug_color = Color(1, 0, 0, 1)
