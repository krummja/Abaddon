
static func Vector2Clamp(vector: Vector2, min_v: float, max_v: float) -> Vector2:
    var x = clampf(vector.x, min_v, max_v)
    var y = clampf(vector.y, min_v, max_v)
    return Vector2(x, y)

static func Vector3Clamp(vector: Vector3, min_v: float, max_v: float) -> Vector3:
    var x = clampf(vector.x, min_v, max_v)
    var y = clampf(vector.y, min_v, max_v)
    var z = clampf(vector.z, min_v, max_v)
    return Vector3(x, y, z)
