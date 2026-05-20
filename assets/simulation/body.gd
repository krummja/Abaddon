class_name Body
extends Node3D

@export_category("Debug")
@export var debug: bool = false
@export var point_count: int = 100
@export var point_rate: float = 4

@export_category("Simulation Settings")
@export var mass: float
@export var velocity: Vector3

@export_category("References")
@export var target: Marker3D

@onready var line := $Line

var _trail_points: PackedVector3Array = []
var _tick_count: int = 0

func _process(_delta: float) -> void:
    _draw_line()

    if debug:
        _draw_debug()

func _physics_process(_delta: float) -> void:
    if debug:
        _tick_count += 1
        if _tick_count == point_rate:
            _push_trail_point()
            _tick_count = 0

func _draw_line() -> void:
    var offset: float = 0.25
    var start = global_position
    var end = Vector3(start.x, target.global_position.y, start.z)

    var trail = end - start
    var direction = trail.normalized()
    var distance = trail.length()

    var _mesh: QuadMesh = line.mesh
    _mesh.size.y = distance - offset
    # _mesh.center_offset.y

func _draw_debug() -> void:
    # DebugDraw3D.draw_line(position, position + velocity)
    DebugDraw3D.draw_points(_trail_points, DebugDraw3D.POINT_TYPE_SQUARE, 0.25)

func _push_trail_point() -> void:
    if len(_trail_points) > point_count:
        _trail_points.remove_at(0)
    _trail_points.append(global_position)
