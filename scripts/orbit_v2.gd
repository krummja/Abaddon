extends MeshInstance3D

@export var debug: bool = false
@export var radius: float = 1.0
@export var width: float = 1.0
@export var resolution: int = 100

var _vertices: PackedVector3Array = PackedVector3Array()
var _indices: PackedInt32Array = PackedInt32Array()

func _ready() -> void:
    mesh = ArrayMesh.new()

    var inner_radius = radius - width

    var surface_array = []
    surface_array.resize(Mesh.ARRAY_MAX)

    var verts = PackedVector3Array()
    var uvs = PackedVector2Array()
    var normals = PackedVector3Array()
    var indices = PackedInt32Array()

    var angle = 0
    var angle_step = 360.0 / resolution

    # Create first vertex
    var px = cos(deg_to_rad(angle)) * inner_radius
    var py = sin(deg_to_rad(angle)) * inner_radius
    var vertex = Vector3(px, 0, py)

    var current_idx = 0
    verts.append(vertex)
    _vertices.append(vertex)
    normals.append(vertex.normalized())
    uvs.append(Vector2(0, 0))

    angle += angle_step / 2
    current_idx += 1

    # Outer circle
    while current_idx <= resolution:
        px = cos(deg_to_rad(angle)) * radius
        py = sin(deg_to_rad(angle)) * radius
        vertex = Vector3(px, 0, py)
        verts.append(vertex)
        _vertices.append(vertex)
        normals.append(vertex.normalized())
        uvs.append(Vector2(0, 0))
        current_idx += 1
        angle += angle_step

    current_idx = resolution * 2

    angle += angle_step / 2

    while current_idx > resolution:
        px = cos(deg_to_rad(angle)) * inner_radius
        py = sin(deg_to_rad(angle)) * inner_radius
        vertex = Vector3(px, 0, py)
        verts.append(vertex)
        _vertices.append(vertex)
        normals.append(vertex.normalized())
        uvs.append(Vector2(0, 0))
        current_idx -= 1
        angle += angle_step

    indices.append_array(_build_indices())
    _indices.append_array(_build_indices())

    surface_array[Mesh.ARRAY_VERTEX] = verts
    surface_array[Mesh.ARRAY_TEX_UV] = uvs
    surface_array[Mesh.ARRAY_NORMAL] = normals
    surface_array[Mesh.ARRAY_INDEX] = indices

    print(verts)
    print(indices)

    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, surface_array)

func _process(_delta: float) -> void:
    if debug:
        _draw_debug()

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

func _draw_debug() -> void:
    DebugDraw3D.draw_points(_vertices)

    for i in _indices:
        var vertex = _vertices[i]
        DebugDraw3D.draw_text(vertex * 1.1, "%d" % i, 64, Color(1, 0, 0, 1))
