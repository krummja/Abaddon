class_name MouseTool
extends Node3D

const RAY_LENGTH = 1_000.0

@export var debug: bool = false

@export var camera: Camera3D
@export var target: Marker3D

var _mouse_pos: Vector2

func _process(_delta: float) -> void:
    if debug:
        _draw_debug()

func _draw_debug() -> void:
    var below_cam = Vector3(
        camera.global_position.x,
        target.global_position.y,
        camera.global_position.z,
    )

    var above_target = Vector3(
        target.global_position.x,
        camera.global_position.y,
        target.global_position.z,
    )

    DebugDraw3D.draw_line(camera.global_position, below_cam)
    DebugDraw3D.draw_line(camera.global_position, target.global_position)
    DebugDraw3D.draw_line(target.global_position, above_target)
    DebugDraw3D.draw_line(camera.global_position, above_target)
    DebugDraw3D.draw_line(below_cam, target.global_position)
