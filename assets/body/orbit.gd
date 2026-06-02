@tool
class_name Orbit
extends MeshInstance3D

const ARC_ACCURACY = 0.0001

const OrbitSolver = preload("res://scripts/orbit_solver.gd")

@export var debug: bool = false

@export_category("Orbital Parameters")
@export var apoapsis: float = 10.0
# @export var periapsis: float = 3.0
@export var eccentricity: float = 0.0

@export_category("Orbital Characteristics")
# @export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eccentricity: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var periapsis: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_major_axis: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_minor_axis: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_parameter: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var center_point: Vector3
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var circumference: float

var _points: PackedVector3Array

func _ready() -> void:
    _points = PackedVector3Array()

    mesh = ImmediateMesh.new()

    set_orbit_parameters()

    position = calculate_focus()

    mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
    mesh.surface_set_normal(Vector3(0, 0, 1))
    mesh.surface_set_uv(Vector2(0, 0))

    _points = OrbitSolver.compute_points(100, semi_major_axis, semi_minor_axis)
    _points.push_back(_points[0])

    for point in _points:
        mesh.surface_add_vertex(point)

    mesh.surface_end()

func _process(_delta: float) -> void:
    if debug:
        _draw_debug()

func calculate_focus() -> Vector3:
    var a = semi_major_axis
    var b = semi_minor_axis
    var c = sqrt(pow(a, 2) - pow(b, 2))
    return Vector3(-c, 0, 0)

func set_orbit_parameters() -> void:
    periapsis = apoapsis * ((1 - eccentricity) / (1 + eccentricity))
    semi_major_axis = (periapsis + apoapsis) / 2
    semi_minor_axis = semi_major_axis * sqrt(abs(1 - pow(eccentricity, 2)))
    semi_parameter = semi_major_axis * (1 - pow(eccentricity, 2))
    center_point = Vector3(periapsis - semi_major_axis, 0, 0)

func _draw_debug() -> void:
    DebugDraw3D.draw_points(_points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1)
    DebugDraw3D.draw_text(global_position + Vector3(0, 3.0, 0), "C: %4.2f" % circumference)
