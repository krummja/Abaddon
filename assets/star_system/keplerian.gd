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
@export var body_color: Color = Color(1, 1, 1, 1)
@export var body_scene: PackedScene
@export var orbit_points: int = 100
@export var orbit_material: Material
@export var target: Marker3D

@export_category("Manual Orbit Parameters")
@export var _apoapsis: float = 10.0
@export var _eccentricity: float = 0.0
@export var _inclination: float = 0.0
@export var _longitude_of_the_ascending_node: float = 0.0
@export_range(0.0, 360.0) var _true_anomaly: float = 0.0

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
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eccentric_anomaly: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var apoapsis_distance: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var periapsis_distance: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var perifocus_distance: float
@export_custom(PROPERTY_HINT_NONE, "suffix:d", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var orbital_period: float

var _points: PackedVector3Array = PackedVector3Array()
var _body: Body
var _orbit: MeshInstance3D

var focus_offset: Vector3:
    get:
        var a = semi_major_axis * Constants.SIZE_SCALE_FACTOR
        var b = semi_minor_axis * Constants.SIZE_SCALE_FACTOR
        var c = sqrt(pow(a, 2) - pow(b, 2))
        return Vector3(c, 0, 0)

var perifocal_frame: Vector3:
    get:
        var p = 0
        var q = 0
        var w = 0
        return Vector3(p, q, w)

func _ready():
    add_to_group("orbital_bodies")
    _body = body_scene.instantiate()
    _body.target = target
    _body.visual_radius = visual_radius
    _body.line_width = visual_radius / 2
    _body.color = body_color
    add_child(_body)

    if data_file:
        var data = DataLoader.load_data_file(data_file)
        var elements = data[1]
        initialize_elements(elements)
        eccentric_anomaly = calculate_eccentric_anomaly()
    else:
        apoapsis_distance = _apoapsis
        eccentricity = _eccentricity
        periapsis_distance = _apoapsis * ((1 - _eccentricity) / (1 + _eccentricity))
        semi_major_axis = (periapsis_distance + apoapsis_distance) / 2
        semi_minor_axis = semi_major_axis * sqrt(abs(1 - pow(eccentricity, 2)))
        inclination = _inclination
        longitude_of_the_ascending_node = _longitude_of_the_ascending_node
        argument_of_the_perifocus = semi_major_axis * (1 - pow(eccentricity, 2))
        perifocus_distance = argument_of_the_perifocus
        longitude_of_the_perifocus = longitude_of_the_ascending_node + argument_of_the_perifocus
        true_anomaly = _true_anomaly

    if has_orbit:
        _position_body()
        draw_orbit()

    _perifocal_reference_frame()

func _physics_process(_delta: float) -> void:
    if has_orbit:
        _position_body()
        _orbit.position = focus_offset
        rotation.y = deg_to_rad(longitude_of_the_ascending_node)
        rotation.z = deg_to_rad(inclination)

    if debug:
        _draw_debug()

func get_body() -> Body:
    return _body

func draw_orbit() -> void:
    _orbit = MeshInstance3D.new()
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

func initialize_elements(data: Dictionary):
    name = data["targetname"]
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

func calculate_eccentric_anomaly(tolerance: float = 1.0e-6, limit: int = 100) -> float:
    var n = 0
    var _ecc = 180 / PI * eccentricity
    var _e = mean_anomaly + _ecc * sin(mean_anomaly)

    var delta_m = 1.0
    var delta_e = 1.0

    while abs(delta_e) > tolerance:
        if n >= limit:
            print("Failed to find eccentric anomaly solution within %d steps" % limit)
            break

        delta_m = mean_anomaly - (_e - _ecc * sin(_e))
        delta_e = delta_m / (1 - eccentricity * cos(_e))
        _e += delta_e
        n += 1

    return _e

func _perifocal_reference_frame() -> Basis:
    var periapsis_vector = (
        Vector3(periapsis_distance, 0, 0)
        .rotated(Vector3.UP, deg_to_rad(longitude_of_the_ascending_node + 180.0))
    ).normalized()

    var arg_of_perifocus_vector = (
        Vector3(0, 0, argument_of_the_perifocus)
        .rotated(Vector3.UP, deg_to_rad(longitude_of_the_ascending_node))
    ).normalized()

    var w_vector = periapsis_vector.cross(arg_of_perifocus_vector).normalized()

    return Basis(periapsis_vector, w_vector, arg_of_perifocus_vector)

func _position_body() -> void:
    var a = semi_major_axis
    var e = eccentricity
    var v = true_anomaly

    var r = (a * (1 - pow(e, 2))) / (1 + e * cos(v))

    var x = r * cos(v)
    var y = r * sin(v)

    _body.position.x = -x * Constants.SIZE_SCALE_FACTOR
    _body.position.z = y * Constants.SIZE_SCALE_FACTOR

func _draw_debug() -> void:
    DebugDraw3D.draw_text(_body.global_position + Vector3.UP, body_name, 64)
    # DebugDraw3D.draw_position(transform)
    # DebugDraw3D.draw_position(_body.global_transform)

    # var _perifocal_frame = _perifocal_reference_frame()

    # var apoapsis_vector = (
    #     Vector3(apoapsis_distance, 0, 0)
    #     .rotated(Vector3.UP, deg_to_rad(longitude_of_the_ascending_node))
    # ).normalized()

    # DebugDraw3D.draw_points([
    #     _perifocal_frame.x * periapsis_distance * Constants.SIZE_SCALE_FACTOR,
    #     _perifocal_frame.z * Constants.SIZE_SCALE_FACTOR,
    #     apoapsis_vector * apoapsis_distance * Constants.SIZE_SCALE_FACTOR,
    # ], DebugDraw3D.POINT_TYPE_SQUARE, 0.5)

    # DebugDraw3D.draw_arrow(global_position, _perifocal_frame.x * 10, Color(1, 0, 0, 1), 0.5, true)
    # DebugDraw3D.draw_arrow(global_position, _perifocal_frame.y * 10, Color(1, 0, 0, 1), 0.5, true)
    # DebugDraw3D.draw_arrow(global_position, _perifocal_frame.z * 10, Color(1, 0, 0, 1), 0.5, true)

    # DebugDraw3D.draw_line(global_position, _perifocal_frame.x.normalized() * eccentricity, Color(0, 1, 0, 1))

    # DebugDraw3D.draw_text(_perifocal_frame.x * 10.5, "p̂", 128, Color(1, 0, 0, 1))
    # DebugDraw3D.draw_text(_perifocal_frame.z * 10.5, "q̂", 128, Color(1, 0, 0, 1))
    # DebugDraw3D.draw_text(_perifocal_frame.y * 10.5, "ŵ", 128, Color(1, 0, 0, 1))
