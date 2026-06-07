class_name Body
extends Node3D

const BodyEvents = preload("res://events/body.gd")

@export_category("Debug")
@export var debug: bool = true

@export_category("Visual Settings")
@export_range(0.1, 100, 0.1) var visual_radius: float = 1.0
@export var color: Color = Color(1, 1, 1, 1)
@export var line_color: Color = Color(1, 1, 1, 1)
@export var line_width: float = 0.1
@export_range(0.0, 1.0) var line_transparency: float = 0.75

@export_category("References")
@export var target: Marker3D

@onready var sphere: MeshInstance3D = $Sphere
@onready var line: MeshInstance3D = $Line
@onready var plane_indicator: MeshInstance3D = $PlaneIndicator
@onready var hover_indicator: MeshInstance3D = $HoverIndicator/HoverIndicator
@onready var hover_animator: AnimationPlayer = $HoverIndicator/AnimationPlayer
@onready var collider: Area3D = $Area3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D

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
    var _hover_mesh: QuadMesh = hover_indicator.mesh

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

    # Set visual parameters of the hover indicator
    _hover_mesh.size = Vector2(visual_radius * 4, visual_radius * 4)

    # Set the sphere's color
    _sphere_mat.set_shader_parameter("color", color)

    # Set the plane altitude line color
    _line_mat.albedo_color = line_color
    line.transparency = line_transparency

    # Set the intersect indicator line color
    _indicator_mat.albedo_color = line_color
    plane_indicator.transparency = line_transparency

func _process(_delta: float) -> void:
    _draw_line()
    _update_indicator()

    if debug:
        _draw_debug()

func _draw_line() -> void:
    line.mesh = ImmediateMesh.new()
    line.global_rotation = Vector3.ZERO

    var _mesh: ImmediateMesh = line.mesh
    var end = Vector3(0, target.global_position.y, 0)

    var distance = Vector3.ZERO.distance_to(end)
    var end_norm = end.normalized()

    var target_pos = end_norm * distance

    _mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
    _mesh.surface_set_normal(Vector3(0, 0, 1))
    _mesh.surface_set_uv(Vector2(0, 0))

    _mesh.surface_add_vertex(Vector3.ZERO)
    _mesh.surface_add_vertex(target_pos)

    _mesh.surface_end()

func _update_indicator() -> void:
    plane_indicator.global_position.y = target.global_position.y
    plane_indicator.global_rotation = Vector3(deg_to_rad(-90), 0, 0)
    var distance = plane_indicator.global_position - sphere.global_position
    plane_indicator.visible = distance.length() > (visual_radius)

func _on_mouse_entered() -> void:
    _is_hovered = true
    hover_animator.play("fade_in")

func _on_mouse_exited() -> void:
    _is_hovered = false
    hover_animator.play("fade_out")

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
    if _is_hovered:
        var camera = get_viewport().get_camera_3d()
        var screen_pos = camera.unproject_position(global_position)
        var body_hovered = BodyEvents.BodyHoveredEvent.new(global_position, screen_pos)
        EventBus.service().broadcast(body_hovered)

    if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
        var body_selected = BodyEvents.BodySelectedEvent.new(global_position)
        EventBus.service().broadcast(body_selected)

func _draw_debug() -> void:
    # print("Debug: %1.2v" % global_position)
    DebugDraw3D.draw_line(global_position, Vector3(global_position.x, target.global_position.y, global_position.z))
    # DebugDraw3D.draw_position(global_transform)
    # DebugDraw3D.draw_position(Transform3D(Basis(), Vector3(global_position.x, target.global_position.y, global_position.z)))
