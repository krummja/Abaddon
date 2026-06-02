class_name SimulationBody
extends Node3D

const BodyEvents = preload("res://events/body.gd")

@export_category("Debug")
@export var debug: bool = false
@export var point_count: int = 100
@export var point_rate: float = 4

@export_category("Simulation Settings")
@export var mass: float
@export var velocity: Vector3

@export_category("Visual Settings")
@export var visual_radius: float = 0.1
@export var color: Color = Color(1, 1, 1, 1)
@export var line_color: Color = Color(1, 1, 1, 1)
@export var line_width: float = 0.1

@export_category("References")
@export var target: Marker3D

@onready var sphere: MeshInstance3D = $Sphere
@onready var line: MeshInstance3D = $Line
@onready var plane_indicator: MeshInstance3D = $PlaneIndicator
@onready var collider: Area3D = $Area3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D

var _trail_points: PackedVector3Array = []
var _tick_count: int = 0
var _is_hovered: bool = false

func _ready():
    add_to_group("bodies")

    # Set up body collision for mouse picking
    var collision_sphere = SphereShape3D.new()
    collision_sphere.radius = visual_radius * 2.0
    collision_shape.shape = collision_sphere
    collider.input_event.connect(_on_input_event)
    collider.mouse_entered.connect(_on_mouse_entered)
    collider.mouse_exited.connect(_on_mouse_exited)

    sphere.mesh = sphere.mesh.duplicate()

    # Duplicate the plane altitude line and its material
    line.mesh = line.mesh.duplicate()
    line.material_override = line.material_override.duplicate()

    # Duplicate the plane intersect indicator and its material
    plane_indicator.mesh = plane_indicator.mesh.duplicate()
    plane_indicator.material_override = plane_indicator.material_override.duplicate()

    # Grab mesh references
    var _sphere_mesh: SphereMesh = sphere.mesh;
    var _line_mesh: ImmediateMesh = line.mesh
    var _indicator_mesh: QuadMesh = plane_indicator.mesh

    # Grab material references
    var _sphere_mat: ShaderMaterial = _sphere_mesh.material
    _sphere_mesh.material = _sphere_mat.duplicate()

    var _line_mat: StandardMaterial3D = line.material_override
    var _indicator_mat: StandardMaterial3D = plane_indicator.material_override

    # Set visual parameters of the sphere
    _sphere_mesh.radius = visual_radius
    _sphere_mesh.height = visual_radius * 2

    # Set visual parameters of the intersect indicator
    _indicator_mesh.size = Vector2(visual_radius * 2, visual_radius * 2)

    # Set the sphere's color
    # sphere.modulate = color
    _sphere_mat.set_shader_parameter("color", color)

    # Set the plane altitude line color
    _line_mat.albedo_color = line_color

    # Set the intersect indicator line color
    _indicator_mat.albedo_color = line_color

func _process(_delta: float) -> void:
    _draw_line()
    _update_indicator()

    if debug:
        _draw_debug()

func _physics_process(_delta: float) -> void:
    if debug:
        _tick_count += 1
        if _tick_count == point_rate:
            _push_trail_point()
            _tick_count = 0

func _draw_line() -> void:
    var start = global_position
    var end = Vector3(start.x, target.global_position.y, start.z)

    var trail: Vector3 = end - start
    var direction: Vector3 = trail.normalized()
    var distance: float = trail.length()

    var dir90: Vector3 = direction.slide(Vector3.BACK).rotated(Vector3.BACK, TAU / 4)
    var width = line_width * dir90

    var _mesh: ImmediateMesh = line.mesh

    _mesh.clear_surfaces()
    _mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

    for i in range(0, 4):
        var x: float = float(i) / float(3)
        var d: Vector3 = (x * distance) * direction

        _mesh.surface_set_normal(Vector3.BACK)
        _mesh.surface_set_uv(Vector2(1.0, x))
        _mesh.surface_add_vertex(d - width)

        _mesh.surface_set_normal(Vector3.BACK)
        _mesh.surface_set_uv(Vector2(0.0, x))
        _mesh.surface_add_vertex(d + width)

    _mesh.surface_end()

func _update_indicator() -> void:
    plane_indicator.global_position.y = target.global_position.y
    var distance = plane_indicator.global_position - sphere.global_position
    plane_indicator.visible = distance.length() > (visual_radius)

func _draw_debug() -> void:
    DebugDraw3D.draw_line(position, position + velocity)
    DebugDraw3D.draw_points(_trail_points, DebugDraw3D.POINT_TYPE_SQUARE, 0.25)

func _push_trail_point() -> void:
    if len(_trail_points) > point_count:
        _trail_points.remove_at(0)
    _trail_points.append(global_position)

func _on_mouse_entered() -> void:
    _is_hovered = true

func _on_mouse_exited() -> void:
    _is_hovered = false

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
    if _is_hovered:
        var camera = get_viewport().get_camera_3d()
        var screen_pos = camera.unproject_position(global_position)
        var body_hovered = BodyEvents.BodyHoveredEvent.new(screen_pos)
        EventBus.service().broadcast(body_hovered)

    if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
        var body_selected = BodyEvents.BodySelectedEvent.new(global_position)
        EventBus.service().broadcast(body_selected)
