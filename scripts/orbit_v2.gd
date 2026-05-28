extends MeshInstance3D

@export var debug: bool = false
@export var radius: float = 1.0
@export var width: float = 1.0
@export var resolution: int = 100

var _debug_vertices := PackedVector3Array()
var _debug_indices := PackedInt32Array()

var _verts = PackedVector3Array()
var _normals = PackedVector3Array()
var _indices = PackedInt32Array()
var _surface_array = []

var _camera: Camera3D

func _ready() -> void:
    _camera = get_viewport().get_camera_3d()
    _build_mesh()

func _process(_delta: float) -> void:
    if debug:
        _draw_debug()

func _build_mesh() -> void:
    mesh = ArrayMesh.new()

    var inner_radius = radius - width

    # var surface_array = []
    _surface_array.resize(Mesh.ARRAY_MAX)

    var angle = 0
    var angle_step = 360.0 / resolution

    # Create first vertex
    var px = cos(deg_to_rad(angle)) * inner_radius
    var py = sin(deg_to_rad(angle)) * inner_radius
    var vertex = Vector3(px, 0, py)

    var current_idx = 0
    _verts.append(vertex)
    _debug_vertices.append(vertex)
    _normals.append(vertex.normalized())

    # angle += angle_step / 2
    current_idx += 1

    # Outer circle
    while current_idx <= resolution:
        px = cos(deg_to_rad(angle)) * radius
        py = sin(deg_to_rad(angle)) * radius

        # Verts
        vertex = Vector3(px, 0, py)
        _verts.append(vertex)
        _debug_vertices.append(vertex)

        # Normals
        _normals.append(vertex.normalized())

        current_idx += 1
        angle += angle_step

    current_idx = resolution

    angle -= angle_step

    while current_idx < resolution * 2:
        px = cos(deg_to_rad(angle)) * inner_radius
        py = sin(deg_to_rad(angle)) * inner_radius

        # Verts
        vertex = Vector3(px, 0, py)
        _verts.append(vertex)
        _debug_vertices.append(vertex)

        # Normals
        _normals.append(vertex.normalized())

        current_idx += 1
        angle -= angle_step

    _indices.append_array(_build_indices())
    _debug_indices.append_array(_build_indices())

    _indices.append_array([_indices[0], _indices[1]])
    _debug_indices.append_array([_indices[0], _indices[1]])

    _surface_array[Mesh.ARRAY_VERTEX] = _verts
    _surface_array[Mesh.ARRAY_NORMAL] = _normals
    _surface_array[Mesh.ARRAY_INDEX] = _indices

    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, _surface_array)

func _build_indices() -> Array[int]:
    var result: Array[int] = [0]
    var left = 1
    var right = (resolution * 2) - 1
    var take_left = true

    while left <= right:
        if take_left:
            result.append(left)
            left += 1
        else:
            result.append(right)
            right -= 1

        take_left = not take_left

    return result

func _build_uvs() -> Array[Vector2]:
    var result: Array[Vector2] = [Vector2(0.0, 1.0)]

    for i in range(1, resolution + 1):
        var u = float(i) / (resolution + 1)
        result.append(Vector2(u, 0.0))

    for i in range(resolution):
        var u = float(i) / resolution
        result.append(Vector2(u, 1.0))

    return result

func _draw_debug() -> void:
    DebugDraw3D.draw_points(_debug_vertices)

    for i in _debug_indices:
        var vec = _debug_vertices[i]
        DebugDraw3D.draw_text(vec * 1.1 + Vector3.UP, "%d" % i, 64, Color(1, 0, 0, 1))
