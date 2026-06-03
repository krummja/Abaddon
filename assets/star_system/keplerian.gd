class_name Keplerian
extends Node3D

const OrbitSolver = preload("res://scripts/orbit_solver.gd")

@export var debug: bool = false

@export_category("BodyV1 Information")
@export var body_name: String

@export_category("Body Parameters")
@export var has_orbit: bool = true
@export var visual_radius: float
@export var body_position: Vector3

@export_category("Orbital Parameters")
@export var distance_scale_factor: float = 100.0
@export var size_scale_factor: float = 10.0
@export var semi_major_axis: KeplerElement
@export var eccentricity: KeplerElement
@export var inclination: KeplerElement
@export var mean_longitude: KeplerElement
@export var longitude_of_perihelion: KeplerElement
@export var longitude_of_ascending_node: KeplerElement
@export var orbit_material: Material

@export var epoch: float = 0.0

@export_category("Dependencies")
@export var target: Marker3D

var _points: PackedVector3Array = PackedVector3Array()

var apoapsis: float:
    get:
        return semi_major_axis.value * (1 + eccentricity.value)

var semi_minor_axis: float:
    get:
        return semi_major_axis.value * sqrt(abs(1 - pow(eccentricity.value, 2)))

var focus_point: Vector3:
    get:
        var a = semi_major_axis.value * size_scale_factor
        var b = semi_minor_axis * size_scale_factor
        var c = sqrt(pow(a, 2) - pow(b, 2))
        return Vector3(-c, 0, 0)

func _ready():
    add_to_group("orbital_bodies")

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
        100,
        semi_major_axis.value * size_scale_factor,
        semi_minor_axis * size_scale_factor,
    )

    _points.push_back(_points[0])

    for point in _points:
        _orbit_mesh.surface_add_vertex(point)

    _orbit_mesh.surface_end()
    add_child(_orbit)

    _orbit.global_position = focus_point
    rotation.y = deg_to_rad(longitude_of_perihelion.value)
    rotation.z = deg_to_rad(inclination.value)

func _draw_debug() -> void:
    # DebugDraw3D.draw_points(_points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1)
    DebugDraw3D.draw_position(Transform3D(Basis(), global_position))
