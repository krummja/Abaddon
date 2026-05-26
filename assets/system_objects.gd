class_name Pickables
extends Node3D

@export var camera_rig: CameraRig

func _ready():
    for child in get_children():
        var _body = child as Body
        _body.camera_rig = camera_rig
