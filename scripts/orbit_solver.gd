const TWO_PI = 2 * PI

static func compute_dpt(r1: float, r2: float, theta: float) -> float:
    var dp: float = 0.0
    var dpt_sin = pow(r1 * sin(theta), 2.0)
    var dpt_cos = pow(r2 * cos(theta), 2.0)
    dp = sqrt(dpt_sin + dpt_cos)
    return dp

static func compute_circumference(r1: float, r2: float, delta_angle: float = 0.0001) -> float:
    var num_integrals = round(TWO_PI / delta_angle)
    var theta = 0.0
    var circ = 0.0
    var dpt = 0.0

    for i in range(num_integrals):
        theta += i * delta_angle
        dpt = compute_dpt(r1, r2, theta)
        circ += dpt

    return circ

static func compute_points(n: int, r1: float, r2: float, delta_angle: float = 0.001) -> PackedVector3Array:
    var points: PackedVector3Array = PackedVector3Array()
    var num_integrals = round(TWO_PI / delta_angle)
    var circumference = compute_circumference(r1, r2, delta_angle)
    var next_point: int = 0
    var run: float = 0
    var theta = 0.0

    for i in range(num_integrals):
        theta += delta_angle
        var subintegral = n * run / circumference

        if subintegral >= next_point:
            var x = r1 * cos(theta)
            var y = r2 * sin(theta)
            points.push_back(Vector3(x, 0, y))
            next_point += 1

        run += compute_dpt(r1, r2, theta)

    return points
