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
@export_file("*.json") var data_file: String

@export_category("Visual Parameters")
@export var has_orbit: bool = true
@export var visual_radius: float
@export var orbit_points: int = 100
@export var orbit_material: Material
@export var target: Marker3D

@export_category("Kepler Elements")
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var epoch: String
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_major_axis: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_minor_axis: float
@export_custom(PROPERTY_HINT_NONE, "suffix:e", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eccentricity: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var inclination: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var longitude_of_the_ascending_node: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var longitude_of_the_perifocus: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var argument_of_the_perifocus: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg/d", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var mean_motion: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var mean_anomaly: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var true_anomaly: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var apoapsis_distance: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var periapsis_distance: float
@export_custom(PROPERTY_HINT_NONE, "suffix:d", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var orbital_period: float

var _points: PackedVector3Array = PackedVector3Array()

var focus_point: Vector3:
    get:
        var a = semi_major_axis * Constants.SIZE_SCALE_FACTOR
        var b = semi_minor_axis * Constants.SIZE_SCALE_FACTOR
        var c = sqrt(pow(a, 2) - pow(b, 2))
        return Vector3(-c, 0, 0)

func _ready():
    add_to_group("orbital_bodies")

    if data_file:
        var data = DataLoader.load_data_file(data_file)
        var elements = data[0]
        initialize_elements(elements)

    if has_orbit:
        draw_orbit()

func _process(_delta: float) -> void:
    if debug:
        _draw_debug()

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

    print(len(_points))

    _points.push_back(_points[0])

    for point in _points:
        _orbit_mesh.surface_add_vertex(point)

    _orbit_mesh.surface_end()
    add_child(_orbit)

    _orbit.global_position = focus_point
    rotation.y = deg_to_rad(longitude_of_the_perifocus)
    rotation.z = deg_to_rad(inclination)

func initialize_elements(data: Dictionary):
    # var targetname = data["targetname"]
    epoch = "JDN %.1f" % data["datetime_jd"]
    eccentricity = data["e"]
    inclination = data["incl"]
    longitude_of_the_ascending_node = data["Omega"]
    argument_of_the_perifocus = data["w"]
    mean_motion = data["n"]
    mean_anomaly = data["M"]
    true_anomaly = data["nu"]
    semi_major_axis = data["a"]
    apoapsis_distance = data["Q"]
    periapsis_distance = data["q"]
    orbital_period = data["P"]

    semi_minor_axis = semi_major_axis * sqrt(abs(1 - pow(eccentricity, 2)))
    longitude_of_the_perifocus = longitude_of_the_ascending_node + argument_of_the_perifocus

func _draw_debug() -> void:
    DebugDraw3D.draw_points(_points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1)
    DebugDraw3D.draw_position(Transform3D(Basis(), global_position))
