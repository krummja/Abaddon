class_name StarSystem
extends Node3D

@export var camera_rig: CameraRig
@export var body_scene: PackedScene

func _ready():
    for child in get_children():
        if child is Keplerian:
            var _keplerian: Keplerian = child
            _keplerian.target = camera_rig.Target
