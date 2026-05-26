extends MeshInstance3D

@export var radius: float = 1.0
@export var resolution: int = 100

func _ready():
    mesh = ArrayMesh.new()

    var surface_array = []
    surface_array.resize(Mesh.ARRAY_MAX)

    var verts = PackedVector3Array()
    var uvs = PackedVector2Array()
    var normals = PackedVector3Array()
    var indices = PackedInt32Array()

    for i in range(-PI / 2, PI / 2):
        var x = radius * sin(i)
        var y = radius * cos(i)
        verts.append(Vector3(x, 0, y))
        verts.append(Vector3(x, 0, -y))

    surface_array[Mesh.ARRAY_VERTEX] = verts
    surface_array[Mesh.ARRAY_TEX_UV] = uvs
    surface_array[Mesh.ARRAY_NORMAL] = normals
    surface_array[Mesh.ARRAY_INDEX] = indices

    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, surface_array)
