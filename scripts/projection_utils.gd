class_name ProjectionUtils

class ScreenRect:
    var p1: Vector2
    var p2: Vector2

    func _init(p_p1: Vector2, p_p2: Vector2) -> void:
        p1 = p_p1
        p2 = p_p2

static func UnprojectVertices(camera: Camera3D, vertex_array: PackedVector3Array) -> Array[Vector2]:
    var unprojected = []
    for vertex in vertex_array:
        var screen_pos = camera.unproject_position(vertex)
        unprojected.push_back(screen_pos)
    return unprojected

static func ResolveScreenBoundingBox(unprojected: Array[Vector2]) -> ScreenRect:
    var p1 = unprojected[0]
    var p2 = p1

    for vert in unprojected:
        p1.x = min(p1.x, vert.x)
        p1.y = min(p1.y, vert.y)
        p2.x = max(p2.x, vert.x)
        p2.y = max(p2.y, vert.y)

    return ScreenRect.new(p1, p2)
