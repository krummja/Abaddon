class_name Body
extends Node3D

const BodyEvents = preload("res://events/body.gd")

@export_category("Debug")
@export var debug: bool = false

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
    _update_line_facing()

    if debug:
        _draw_debug()

func _physics_process(_delta: float) -> void:
    if debug:
        pass

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

func _update_line_facing() -> void:
    var camera_rig_root: Node3D = target.get_parent()
    var camera: Camera3D = camera_rig_root.get_child(0).get_child(0)
    var camera_position = camera.global_position
    line.look_at(Vector3(camera_position.x, 0, camera_position.z), Vector3.UP, true)

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
    var camera_rig_root: Node3D = target.get_parent()
    var camera: Camera3D = camera_rig_root.get_child(0).get_child(0)
    var camera_position = camera.global_position
    var line_end = Vector3(camera_position.x, 0, camera_position.z)
    DebugDraw3D.draw_line(plane_indicator.global_position, line_end, Color(1, 0, 0, 1))
    DebugDraw3D.draw_line(camera_position, line_end, Color(1, 0, 0, 1))
    DebugDraw3D.draw_position(camera.global_transform)
