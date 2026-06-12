@icon("res://textures/planet_icon.svg")

class_name PlanetBody
extends SystemBody

@export var color: Color
@export var radius: float

var body_visual: BodyVisual
var orbit_visual: OrbitVisual
var plane_visual: PlaneVisual
var selectable: Selectable

func setup() -> void:
    Debug.debug("BEGIN PlanetBody %s" % name)

    body_visual = BodyVisual.new(self, color, radius)
    add_child(body_visual)

    orbit_visual = OrbitVisual.new(self)
    add_child(orbit_visual)

    plane_visual = PlaneVisual.new()
    add_child(plane_visual)

    selectable = Selectable.new()
    add_child(selectable)

    Debug.debug("  END PlanetBody %s" % name)

func _physics_process(_delta: float) -> void:
    if debug:
        _draw_debug()

    # Set the position of the orbit component relative to object position
    _set_orbit_position()

    # Set the position of the body component relative to the object position
    _set_body_position()

    # Rotate the entire object to align with LAAN and inclination
    _set_rotation()

func _set_rotation() -> void:
    rotation.y = deg_to_rad(longitude_of_the_ascending_node)
    rotation.z = deg_to_rad(inclination)

func _set_orbit_position() -> void:
    orbit_visual.position = orbit_visual.focus_offset

func _set_body_position() -> void:
    var a = semi_major_axis
    var e = eccentricity
    var v = true_anomaly

    var r = (a * (1 - pow(e, 2))) / (1 + e * cos(v))
    var x = r * cos(v)
    var y = r * sin(v)

    body_visual.position.x = -x * Constants.DISTANCE_SCALE_FACTOR
    body_visual.position.z = y * Constants.DISTANCE_SCALE_FACTOR

func _draw_debug() -> void:
    DebugDraw3D.draw_position(global_transform, Color.RED)
    DebugDraw3D.draw_text(global_position + Vector3.UP, "P", 128, Color.RED)

    DebugDraw3D.draw_position(body_visual.global_transform, Color.GREEN)
    DebugDraw3D.draw_text(body_visual.global_position + Vector3.UP, "B", 128, Color.GREEN)

    DebugDraw3D.draw_position(orbit_visual.global_transform, Color.BLUE)
    DebugDraw3D.draw_text(orbit_visual.global_position + Vector3.UP, "O", 128, Color.BLUE)
