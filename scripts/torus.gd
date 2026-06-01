extends MeshInstance3D


@export var debug: bool = false
@export var debug_verts: bool = true
@export var debug_norms: bool = false
@export var debug_indices: bool = false

@export var rings = 15
@export var ring_segments = 15
@export var outer_radius: float = 5
@export var inner_radius: float = 1


var _vertices := PackedVector3Array()
var _tangents := PackedFloat64Array()
var _normals := PackedVector3Array()
var _uvs := PackedVector2Array()
var _indices := PackedInt32Array()

var _surface_array = []


func _ready():
    mesh = ArrayMesh.new()

    _surface_array.resize(Mesh.ARRAY_MAX)

    _build_torus()

    _surface_array[Mesh.ARRAY_VERTEX] = _vertices
    _surface_array[Mesh.ARRAY_INDEX] = _indices
    _surface_array[Mesh.ARRAY_TANGENT] = _tangents
    _surface_array[Mesh.ARRAY_NORMAL] = _normals
    _surface_array[Mesh.ARRAY_TEX_UV] = _uvs

    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _surface_array)

func _process(_delta: float) -> void:
    if debug:
        _draw_debug()

func _build_torus() -> void:
    var min_radius = inner_radius
    var max_radius = outer_radius

    if (min_radius > max_radius):
        var _max = max_radius
        var _min = min_radius
        max_radius = _min
        min_radius = _max

    var radius = (max_radius - min_radius) * 0.5

    for i in range(rings + 1):
        var prev_row = (i - 1) * (ring_segments + 1)
        var this_row = i * (ring_segments + 1)
        var increment_i = float(i) / rings
        var angle_i = increment_i * TAU

        var normali = Vector2(0.0, -1.0) if (i == rings) else Vector2(-sin(angle_i), -cos(angle_i))

        for j in range(ring_segments + 1):
            var increment_j = float(j) / ring_segments
            var angle_j = increment_j * TAU

            var normalj = Vector2(-1.0, 0.0) if (j == ring_segments) else Vector2(-cos(angle_j), sin(angle_j))
            var normalk = normalj * radius + Vector2(min_radius + radius, 0)

            _vertices.push_back(Vector3(normali.x * normalk.x, normalk.y, normali.y * normalk.x))
            _normals.push_back(Vector3(normali.x * normalj.x, normalj.y, normali.y * normalj.x))
            _tangents.append_array([normali.y, 0.0, -normali.x, 1.0])
            _uvs.push_back(Vector2(increment_i, increment_j))

            if i > 0 && j > 0:
                _indices.push_back(this_row + j - 1)
                _indices.push_back(prev_row + j)
                _indices.push_back(prev_row + j - 1)

                _indices.push_back(this_row + j - 1)
                _indices.push_back(this_row + j)
                _indices.push_back(prev_row + j)

func _draw_debug() -> void:
    if debug_verts:
        DebugDraw3D.draw_points(_vertices, DebugDraw3D.POINT_TYPE_SQUARE, 0.1)

    if debug_norms:
        for i in range(len(_vertices)):
            var vert = _vertices[i]
            var normal = _normals[i]
            DebugDraw3D.draw_line(vert, vert + normal, Color(0, 0, 1, 1))

    if debug_indices:
        for i in range(len(_vertices)):
            var vert = _vertices[i]
            var norm = _normals[i]
            var index = _indices[i]

            DebugDraw3D.draw_text(
                vert + (norm * 0.5),
                "%d" % index,
                48,
                Color(1, 0, 0, 1),
            )
