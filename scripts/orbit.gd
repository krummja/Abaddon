extends MeshInstance3D

const ARC_ACCURACY = 0.0001

@export_category("Geometry Parameters")
@export_range(0.0001, 0.01) var sample_angle: float = 0.001
@export_range(0.01, 0.9) var arc_length: float = 0.1

@export_category("Orbital Parameters")
@export var apoapsis: float = 10.0
@export var periapsis: float = 3.0

@export_category("Orbital Characteristics")
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eccentricity: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_major_axis: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_minor_axis: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_parameter: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var center_point: Vector3


func _ready() -> void:
    set_orbit_parameters()
    position = calculate_focus()

    mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
    mesh.surface_set_normal(Vector3(0, 0, 1))
    mesh.surface_set_uv(Vector2(0, 0))

    var ellipse_points = make_ellipse()
    for point in ellipse_points:
        mesh.surface_add_vertex(point)

    mesh.surface_end()

func calculate_focus() -> Vector3:
    var a = semi_major_axis
    var b = semi_minor_axis
    var c = sqrt(pow(a, 2) - pow(b, 2))
    return Vector3(-c, 0, 0)

func make_ellipse() -> PackedVector3Array:
    var points: PackedVector3Array = []

    var angle: float = 0.0
    var circumference = get_length_of_ellipse(sample_angle)
    var first_point: Vector3 = Vector3.ZERO

    for p in range(0, (circumference / arc_length)):
        angle = get_angle_for_arc_length_recursively(0, arc_length, angle, sample_angle)
        var x = semi_major_axis * cos(angle)
        var y = semi_minor_axis * sin(angle)
        if first_point == Vector3.ZERO:
            first_point = Vector3(x, 0, y)

        points.append(Vector3(x, 0, y))

    points.append(first_point)

    return points

func set_orbit_parameters():
    eccentricity = (apoapsis - periapsis) / (apoapsis + periapsis)
    semi_major_axis = (periapsis + apoapsis) / 2
    semi_minor_axis = semi_major_axis * sqrt(abs(1 - pow(eccentricity, 2)))
    semi_parameter = semi_major_axis * (1 - pow(eccentricity, 2))
    center_point = Vector3(periapsis - semi_major_axis, 0, 0)

func get_length_of_ellipse(delta_angle: float) -> float:
    var length: float = 0.0
    var num_integrals: int = round(PI * 2.0 / delta_angle)
    for i in range(num_integrals):
        length += compute_arc_over_angle(semi_major_axis, semi_minor_axis, i * delta_angle, delta_angle)
    return length

func get_angle_for_arc_length_recursively(
    current_arc_pos: float,
    goal_arc_pos: float,
    angle: float,
    angle_seg: float,
) -> float:
    # Calculate arc length at new angle
    var next_seg_length: float = compute_arc_over_angle(semi_major_axis, semi_minor_axis, angle + angle_seg, angle_seg)

    # If we've overshot, reduce the delta angle and retry
    if (current_arc_pos + next_seg_length) > goal_arc_pos:
        return get_angle_for_arc_length_recursively(current_arc_pos, goal_arc_pos, angle, angle_seg / 2)

    # We're below our current goal value but not in range
    elif (current_arc_pos + next_seg_length) < goal_arc_pos - ((goal_arc_pos - current_arc_pos) * ARC_ACCURACY):
        return get_angle_for_arc_length_recursively(current_arc_pos + next_seg_length, goal_arc_pos, angle + angle_seg, angle_seg)

    # Current arc length is in range (within error) so return the angle
    return angle

func compute_arc_over_angle(r1: float, r2: float, angle: float, angle_seg: float) -> float:
    var distance: float = 0.0
    var dpt_sin = pow(r1 * sin(angle), 2.0)
    var dpt_cos = pow(r2 * cos(angle), 2.0)
    distance = sqrt(dpt_sin + dpt_cos)
    return distance * angle_seg
