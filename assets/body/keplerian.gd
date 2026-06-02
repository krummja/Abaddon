class_name Keplerian
extends Node3D

@export var debug: bool = false

@export_category("BodyV1 Information")
@export var body_name: String

@export_category("Body Parameters")
@export var has_orbit: bool = true
@export var visual_radius: float
@export var body_position: Vector3

@export_category("Orbital Parameters")
@export var apoapsis: float = 1.0
# @export var periapsis: float = 1.0
@export var eccentricity: float = 0.0
@export var epoch: float = 0.0

@export_category("Dependencies")
@export var target: Marker3D
@export var body: PackedScene
@export var orbit: PackedScene

func create_body():
    var _body: BodyV1 = body.instantiate()
    _body.target = target
    _body.visual_radius = visual_radius
    _body.position = body_position
    add_child(_body)

    if has_orbit:
        var _orbit: Orbit = orbit.instantiate()
        if debug:
            _orbit.debug = debug
        _orbit.apoapsis = apoapsis
        _orbit.eccentricity = eccentricity
        add_child(_orbit)
