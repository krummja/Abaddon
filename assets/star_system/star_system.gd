class_name StarSystem
extends Node3D

@export var debug: bool = false

@export var camera_rig: CameraRig
@export var galactic_environment: WorldEnvironment

func _ready() -> void:
    for child in get_children():
        if child is Keplerian:
            var _keplerian: Keplerian = child
            _keplerian.target = camera_rig.Target

func _process(_delta: float) -> void:
    if debug:
        _draw_debug()

func _draw_debug() -> void:
    # DebugDraw3D.draw_line(Vector3(0,-400,0), Vector3(0,400,0))
    DebugDraw3D.draw_box(Vector3.ONE * -50, Quaternion(), Vector3.ONE * 100)
    DebugDraw3D.draw_text(Vector3(0, 0, -50), "N", 512)
