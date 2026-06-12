class_name OrbitVisual
extends MeshInstance3D

const OrbitSolver = preload("res://scripts/orbit_solver.gd")
const OrbitEvents = preload("res://assets/star_system/events/orbit.gd")

var parent_body: SystemBody
var color: Color

var orbit_points: PackedVector3Array = PackedVector3Array()
var orbit_resolution: int = 100

var orbit_mesh: ImmediateMesh:
    get:
        return mesh
    set(value):
        mesh = value

var orbit_material: Material:
    get:
        return material_override
    set(value):
        material_override = value

var focus_offset: Vector3:
    get:
        var a = parent_body.semi_major_axis * Constants.DISTANCE_SCALE_FACTOR
        var b = parent_body.semi_minor_axis * Constants.DISTANCE_SCALE_FACTOR
        var c = sqrt(pow(a, 2) - pow(b, 2))
        return Vector3(c, 0, 0)

func _init(p_parent: SystemBody, p_color: Color = Color(1, 1, 1, 1), p_resolution: int = 100) -> void:
    Debug.debug("BEGIN OrbitVisual for %s" % p_parent.name)

    name = "%s OrbitVisual" % p_parent.name
    parent_body = p_parent
    color = p_color
    orbit_resolution = p_resolution

    Debug.debug("  END OrbitVisual for %s" % parent_body.name)

func _ready() -> void:
    if orbit_mesh == null:
        orbit_mesh = ImmediateMesh.new()

    if orbit_material == null:
        orbit_material = StandardMaterial3D.new()
        orbit_material.emission_enabled = true
        orbit_material.emission = color

func _physics_process(_delta: float) -> void:
    draw_orbit()

func draw_orbit() -> void:
    orbit_mesh = ImmediateMesh.new()

    orbit_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
    orbit_mesh.surface_set_normal(Vector3(0, 0, 1))
    orbit_mesh.surface_set_uv(Vector2(0, 0))

    orbit_points = OrbitSolver.compute_points(
        orbit_resolution,
        parent_body.semi_major_axis * Constants.DISTANCE_SCALE_FACTOR,
        parent_body.semi_minor_axis * Constants.DISTANCE_SCALE_FACTOR,
    )

    # Add the first vertex to the end to complete the loop
    orbit_points.push_back(orbit_points[0])

    for point in orbit_points:
        orbit_mesh.surface_add_vertex(point)

    orbit_mesh.surface_end()
