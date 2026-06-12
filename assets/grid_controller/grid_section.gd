class_name GridSection
extends MeshInstance3D

signal section_entered(section: GridSection)
signal section_exited(section: GridSection)
signal section_destroyed(section: GridSection)

@export var debug: bool = false
@export var unit_size: float = 5.0

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

func initialize_shader(p_fade_end: float, p_fade_start: float, p_unit_size: float) -> void:
    set_instance_shader_parameter("fadeEnd", p_fade_end)
    set_instance_shader_parameter("fadeStart", p_fade_start)
    set_instance_shader_parameter("unitSize", p_unit_size)

    if debug:
        var _fade_end = get_instance_shader_parameter("fadeEnd")
        var _fade_start = get_instance_shader_parameter("fadeStart")
        var _unit_size = get_instance_shader_parameter("unitSize")
        Debug.debug("%d : %d : %d" % [_fade_end, _fade_start, _unit_size])

func update_shader(p_center_offset: Vector3) -> void:
    set_instance_shader_parameter("centerOffset", p_center_offset)

func set_size(size: int) -> void:
    _size = size
    _mesh.size.x = size
    _mesh.size.y = size

func enable_boundary() -> void:
    boundary.monitoring = true

func disable_boundary() -> void:
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
