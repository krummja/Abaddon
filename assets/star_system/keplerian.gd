class_name Keplerian
extends Node3D

const OrbitSolver = preload("res://scripts/orbit_solver.gd")
const TimeEvents = preload("res://events/time.gd")

@export var debug: bool = false

@export_category("Ephemeris Date")
@export_range(2000, 4000) var ephemeris_year: int = 2000
@export var ephemeris_month: Time.Month = Time.MONTH_JANUARY
@export_range(1, 31) var ephemeris_day: int = 1

@export_category("Body Information")
@export var body_name: String

@export_category("Visual Parameters")
@export var has_orbit: bool = true
@export var visual_radius: float
@export var orbit_points: int = 100
@export var orbit_material: Material
@export var target: Marker3D

@export_category("Orbital Constants")
@export_custom(PROPERTY_HINT_NONE, "suffix:au") var semi_major_axis: float = 1.00000011
@export_custom(PROPERTY_HINT_NONE, "suffix:rad") var eccentricity: float = 0.01671022
@export_custom(PROPERTY_HINT_NONE, "suffix:deg") var inclination: float = 0.00005
@export_custom(PROPERTY_HINT_NONE, "suffix:deg") var mean_longitude: float = -11.26064
@export_custom(PROPERTY_HINT_NONE, "suffix:deg") var longitude_of_perihelion: float = 102.94719
@export_custom(PROPERTY_HINT_NONE, "suffix:deg") var longitude_of_the_ascending_node: float = 0.0

@export_category("Orbital Corrections")
@export_custom(PROPERTY_HINT_NONE, "suffix:au/Cy") var _semi_major_axis: float = 0.00000562
@export_custom(PROPERTY_HINT_NONE, "suffix:rad/Cy") var _eccentricity: float = -0.00004392
@export_custom(PROPERTY_HINT_NONE, "suffix:deg/Cy") var _inclination: float = -0.01294668
@export_custom(PROPERTY_HINT_NONE, "suffix:deg/Cy") var _mean_longitude: float = 35999.37244981
@export_custom(PROPERTY_HINT_NONE, "suffix:deg/Cy") var _longitude_of_perihelion: float = 0.32327364
@export_custom(PROPERTY_HINT_NONE, "suffix:deg/Cy") var _longitude_of_the_ascending_node: float = 0.0

@export_category("Additional Corrections")
@export var drift_coefficient: float = 0.0
@export var cosine_amplitude_coefficient: float = 0.0
@export var sine_amplitude_coefficient: float = 0.0
@export var frequency: float = 0.0

@export_category("Ephemeris Values")
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eph_semi_major_axis: float
@export_custom(PROPERTY_HINT_NONE, "suffix:rad", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eph_eccentricity: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eph_inclination: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eph_mean_longitude: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eph_longitude_of_perihelion: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eph_longitude_of_the_ascending_node: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var argument_of_perihelion: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var mean_anomaly: float

var _points: PackedVector3Array = PackedVector3Array()

var apoapsis: float:
    get:
        return semi_major_axis * (1 + eccentricity)

var semi_minor_axis: float:
    get:
        return semi_major_axis * sqrt(abs(1 - pow(eccentricity, 2)))

var focus_point: Vector3:
    get:
        var a = semi_major_axis * Constants.SIZE_SCALE_FACTOR
        var b = semi_minor_axis * Constants.SIZE_SCALE_FACTOR
        var c = sqrt(pow(a, 2) - pow(b, 2))
        return Vector3(-c, 0, 0)

func _ready():
    add_to_group("orbital_bodies")

    calculate_ephemeris_coordinates({
        "year": ephemeris_year,
        "month": ephemeris_month,
        "day": ephemeris_day,
        "hour": 0,
        "minute": 0,
        "second": 0,
    })

    if has_orbit:
        draw_orbit()

func _process(_delta: float) -> void:
    if debug:
        _draw_debug()

func calculate_ephemeris_coordinates(date: Dictionary):
    var t = Time.get_unix_time_from_datetime_dict(date) + Constants.UNIX_TDB_APPROX

    eph_semi_major_axis = _ephemeris_value(semi_major_axis, _semi_major_axis, t)
    eph_eccentricity = _ephemeris_value(eccentricity, _eccentricity, t)
    eph_inclination = _ephemeris_value(inclination, _inclination, t)
    eph_mean_longitude = _ephemeris_value(mean_longitude, _mean_longitude, t)
    eph_longitude_of_perihelion = _ephemeris_value(longitude_of_perihelion, _longitude_of_perihelion, t)
    eph_longitude_of_the_ascending_node = _ephemeris_value(longitude_of_the_ascending_node, _longitude_of_the_ascending_node, t)

    var _argument_of_perihelion = eph_longitude_of_perihelion - eph_longitude_of_the_ascending_node
    var _argument_of_perihelion_deg = MathUtils.GetDecimalPart(_argument_of_perihelion) * 360
    argument_of_perihelion = MathUtils.RemapDegreeRange(_argument_of_perihelion_deg)

    var _mean_anomaly = (
        eph_mean_longitude
        - eph_longitude_of_perihelion
        + (drift_coefficient * pow(t, 2))
        + cosine_amplitude_coefficient * cos(frequency * t)
        + sine_amplitude_coefficient * sin(frequency * t)
    )

    var _mean_anomaly_deg = MathUtils.GetDecimalPart(_mean_anomaly) * 360
    mean_anomaly = MathUtils.RemapDegreeRange(_mean_anomaly_deg)

func draw_orbit() -> void:
    var _orbit = MeshInstance3D.new()
    _orbit.material_override = orbit_material

    _orbit.mesh = ImmediateMesh.new()
    var _orbit_mesh: ImmediateMesh = _orbit.mesh

    _orbit_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
    _orbit_mesh.surface_set_normal(Vector3(0, 0, 1))
    _orbit_mesh.surface_set_uv(Vector2(0, 0))

    _points = OrbitSolver.compute_points(
        orbit_points,
        semi_major_axis * Constants.SIZE_SCALE_FACTOR,
        semi_minor_axis * Constants.SIZE_SCALE_FACTOR,
    )

    _points.push_back(_points[0])

    for point in _points:
        _orbit_mesh.surface_add_vertex(point)

    _orbit_mesh.surface_end()
    add_child(_orbit)

    _orbit.global_position = focus_point
    rotation.y = deg_to_rad(longitude_of_perihelion)
    rotation.z = deg_to_rad(inclination)

func _ephemeris_value(constant: float, correction: float, ephemeris: float) -> float:
    return constant + (correction * ephemeris)

func _draw_debug() -> void:
    DebugDraw3D.draw_points(_points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1)
    DebugDraw3D.draw_position(Transform3D(Basis(), global_position))
