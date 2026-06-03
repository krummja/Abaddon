class_name StarSystem
extends Node3D

@export var distance_scale_factor: float = 100.0
@export var size_scale_factor: float = 10.0
@export var camera_rig: CameraRig
@export var body_scene: PackedScene

func _ready():
    for child in get_children():
        var _keplerian: Keplerian = child
        _keplerian.target = camera_rig.Target
        _keplerian.distance_scale_factor = distance_scale_factor
        _keplerian.size_scale_factor = size_scale_factor

    # _add_body("Sol", 10.0, false)
    # _add_body("Mercury", 1.0, 38.75, 0.20563069)
    # _add_body("Venus", 2.0, 72.3, 0.00677323)
    # _add_body("Earth", 2.0, 100.0)
    # _add_body("Mars", 1.5, 152.4, 0.09341233)
    # _add_body("Jupiter", 5.0, 520.3, 0.04839266)
    # _add_body("Saturn", 4.0, 953.7, 0.05415060)
    # _add_body("Uranus", 3.0, 1919.1, 0.04716771)
    # _add_body("Neptune", 3.0, 3948.0, 0.00858587)

func _add_body(body_name: String, radius: float, has_orbit: bool = true) -> void:
    var keplerian: Keplerian = body_scene.instantiate()
    keplerian.has_orbit = has_orbit
    keplerian.body_name = name
    keplerian.target = camera_rig.Target
    keplerian.visual_radius = radius
    keplerian.distance_scale_factor = distance_scale_factor
    keplerian.size_scale_factor = size_scale_factor
    add_child(keplerian)
