
static func Vector2Clamp(vector: Vector2, min_v: float, max_v: float) -> Vector2:
    var x = clampf(vector.x, min_v, max_v)
    var y = clampf(vector.y, min_v, max_v)
    return Vector2(x, y)

static func Vector3Clamp(vector: Vector3, min_v: float, max_v: float) -> Vector3:
    var x = clampf(vector.x, min_v, max_v)
    var y = clampf(vector.y, min_v, max_v)
    var z = clampf(vector.z, min_v, max_v)
    return Vector3(x, y, z)

static func SubdivideDistanceToPoints(origin: Vector3, direction: Vector3, total_length: float, segments: int) -> Array[Vector3]:
    var result_vectors: Array[Vector3] = []
    var step_distance = total_length / segments
    var unit_direction = direction.normalized()

    for i in range(segments):
        var current_distance = (i + 1) * step_distance
        var point_vector = origin + (unit_direction * current_distance)
        result_vectors.append(point_vector)

    return result_vectors

static func SubdivideDistanceToPointsBounded(origin: Vector3, target: Vector3, segments: int) -> Array[Vector3]:
    var result_vectors: Array[Vector3] = []

    var direction = target - origin
    var total_length = direction.length()

    result_vectors = SubdivideDistanceToPoints(origin, direction, total_length, segments)

    return result_vectors

