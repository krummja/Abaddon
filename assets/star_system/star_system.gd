class_name StarSystem
extends Node3D

@export var distance_scale_factor: float = 10.0
@export var size_scale_factor: float = 10.0
@export var camera_rig: CameraRig
@export var body_scene: PackedScene

func _ready():
    _add_body("Sol", 10.0, 0.0, 0.0, false)
    _add_body("Mercury", 1.0, 38.75, 0.20563069)
    _add_body("Venus", 2.0, 72.3, 0.00677323)
    _add_body("Earth", 2.0, 100.0, 0.01671022)
    _add_body("Mars", 1.5, 152.4, 0.09341233)
    _add_body("Jupiter", 5.0, 520.3, 0.04839266)
    _add_body("Saturn", 4.0, 953.7, 0.05415060)
    _add_body("Uranus", 3.0, 1919.1, 0.04716771)
    _add_body("Neptune", 3.0, 3948.0, 0.00858587)

func _add_body(body_name: String, radius: float, offset: float, ecc: float = 0.0, has_orbit: bool = true) -> void:
    var keplerian: Keplerian = body_scene.instantiate()
    keplerian.has_orbit = has_orbit
    keplerian.body_name = name
    keplerian.apoapsis = offset / distance_scale_factor
    # keplerian.periapsis = offset / distance_scale_factor
    keplerian.eccentricity = ecc
    keplerian.target = camera_rig.Target
    keplerian.visual_radius = radius / size_scale_factor
    keplerian.body_position = Vector3(offset / distance_scale_factor, 0, 0)
    add_child(keplerian)

    keplerian.create_body()
