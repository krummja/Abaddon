extends MeshInstance3D

@export var debug: bool = false
@export var radius: float = 1.0
@export var width: float = 1.0
@export var resolution: int = 100

var _vertices: Array[Vector3] = []
var _indices: Array[int] = []

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
    var angle_step = 180.0 / resolution

    for i in range(resolution):
        var px = cos(angle) * radius
        var py = sin(angle) * radius

        var vert = Vector3(px, 1, py)
        verts.append(vert)
        normals.append(vert.normalized())
        uvs.append(Vector2(0, 0))
        angle += angle_step

    for j in range(resolution):
        var px = cos(angle) * inner_radius
        var py = sin(angle) * inner_radius

        var vert = Vector3(px, 1, py)
        verts.append(vert)
        normals.append(vert.normalized())
        uvs.append(Vector2(0, 0))
        angle += angle_step

    surface_array[Mesh.ARRAY_VERTEX] = verts
    surface_array[Mesh.ARRAY_TEX_UV] = uvs
    surface_array[Mesh.ARRAY_NORMAL] = normals
    surface_array[Mesh.ARRAY_INDEX] = indices

    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, surface_array)

func _process(_delta: float) -> void:
    if debug:
        _draw_debug()

func _draw_debug() -> void:
    for i in range(len(_indices)):
        var index = _indices[i]
        var vertex = _vertices[index]
        DebugDraw3D.draw_text(Vector3(vertex.x, vertex.y + 1, vertex.z), "%d" % index, 64, Color(1, 0, 0, 1))
