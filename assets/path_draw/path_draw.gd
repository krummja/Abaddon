class_name PathDraw
extends Node3D

@export var head_width: float = 0.5
@export var head_length: float = 1.0
@export var thickness: float = 0.1
@export var points: int = 3
@export var y_offset: float = 0.5

@onready var endpoint: Node3D = $Target
@onready var line_mesh: MeshInstance3D = $LineMesh
@onready var arrowhead: MeshInstance3D = $Target/Arrowhead

func _ready():
    translate(Vector3(0, y_offset, 0))
    draw_arrow()

func _process(_delta: float) -> void:
    draw_arrow()

func draw_arrow() -> void:
    var a = endpoint.global_transform.origin
    var b = global_transform.origin
    # DebugDraw3D.draw_gizmo(endpoint.global_transform)
    # DebugDraw3D.draw_position(global_transform)
    # DebugDraw3D.draw_arrow(a, b, Color(1, 0, 1, 1), 0.1)

    # draw_arrowhead()
    draw_line()

func draw_arrowhead() -> void:
    var _mesh: ImmediateMesh = arrowhead.mesh

    _mesh.clear_surfaces()
    _mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

    for i in range(3):
        _mesh.surface_set_normal(Vector3.UP)
        _mesh.surface_add_vertex(Vector3(0, 0, -head_width))

        _mesh.surface_set_normal(Vector3.UP)
        _mesh.surface_add_vertex(Vector3(0, 0, head_width))

        _mesh.surface_set_normal(Vector3.UP)
        _mesh.surface_add_vertex(Vector3(-head_length, 0, 0))

    _mesh.surface_end()

func draw_line() -> void:
    var offset: Vector3 = Vector3.ZERO

    var start: Vector3 = global_position - offset
    var end: Vector3 = endpoint.global_position - offset

    var trail: Vector3 = end - start
    var direction: Vector3 = trail.normalized()
    var distance: float = trail.length()

    var dir90: Vector3 = direction.slide(Vector3.UP).rotated(Vector3.UP, TAU / 4)
    var width: Vector3 = thickness * dir90

    var _mesh: ImmediateMesh = line_mesh.mesh

    _mesh.clear_surfaces()
    _mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

    for i in range(0, points + 1):
        var x: float = float(i) / float(points)
        var d: Vector3 = (x * distance) * direction

        _mesh.surface_set_normal(Vector3.UP)
        _mesh.surface_set_uv(Vector2(1.0, x))
        _mesh.surface_add_vertex(d - width)

        _mesh.surface_set_normal(Vector3.UP)
        _mesh.surface_set_uv(Vector2(0.0, x))
        _mesh.surface_add_vertex(d + width)

    line_mesh.mesh.surface_end()
