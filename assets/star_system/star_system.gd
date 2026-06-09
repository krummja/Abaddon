class_name StarSystem
extends Node3D

@export var debug: bool = false

@export var camera_rig: CameraRig

var target: Marker3D:
    get:
        return camera_rig.Target

# func _ready() -> void:
#     for child in get_children():
#         if child is Keplerian:
#             var _keplerian: Keplerian = child
#             _keplerian.target = camera_rig.Target

func _process(_delta: float) -> void:
    if debug:
        _draw_debug()

func _draw_debug() -> void:
    var text_size = 64;

    for x in range(-10, 11):
        DebugDraw3D.draw_text(
            Vector3(x * Constants.DISTANCE_SCALE_FACTOR, target.global_position.y + 0.1, 0),
            "%s" % x,
            text_size,
            Color(0.8, 0.8, 0.8, 1.0),
        )

    for y in range(-10, 11):
        DebugDraw3D.draw_text(
            Vector3(0, target.global_position.y + 0.1, y * Constants.DISTANCE_SCALE_FACTOR),
            "%s" % y,
            text_size,
            Color(0.8, 0.8, 0.8, 1.0),
        )
