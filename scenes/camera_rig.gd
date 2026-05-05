extends Node3D

@export var scroll_speed: float = 10.0
@export var zoom_speed: float = 5.0
@export var default_distance: float = 100.0
@export var rotation_speed: float = 10.0

@onready var rotation_arm = $Rotation
@onready var elevation_arm = $Rotation/Elevation
@onready var camera = $Rotation/Elevation/Camera3D

var _move_speed: Vector2
var _scroll_speed: float
var _is_zoom_in: bool
var _is_zoom_out: bool

var _rotation: float
var _elevation: float
var _distance: float

func _ready() -> void:
    _distance = default_distance
    _rotation = rotation_arm.transform.basis.get_rotation_quaternion().get_euler().y
    _elevation = elevation_arm.transform.basis.get_rotation_quaternion().get_euler().x

func _process(delta: float) -> void:
    _process_transform(delta)

func _process_transform(delta: float):
    # Elevation and Rotation
    _elevation += -_move_speed.y * delta * rotation_speed
    _rotation += -_move_speed.x * delta * rotation_speed

    if _elevation < -PI / 2:
        _elevation = -PI / 2
    if _elevation > PI / 2:
        _elevation = PI / 2

    rotation_arm.transform.basis = Basis(Quaternion.from_euler(Vector3(0, _rotation, 0)))
    elevation_arm.transform.basis = Basis(Quaternion.from_euler(Vector3(_elevation, 0, 0)))

    _move_speed = Vector2.ZERO

    # Zoom
    _distance += _scroll_speed * delta

    if _distance < 0.1:
        _distance = 0.1

    camera.size = _distance

    _scroll_speed = 0

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _process_mouse_rotation_event(event)
    elif event is InputEventMouseButton:
        _process_mouse_scroll_event(event)

func _process_mouse_rotation_event(event: InputEventMouseMotion):
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        _scroll_speed = event.relative.y * scroll_speed
    elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        _move_speed = event.relative

func _process_mouse_scroll_event(event: InputEventMouseButton):
    if event.button_index == MOUSE_BUTTON_WHEEL_UP:
        _scroll_speed = -1 * zoom_speed
    elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
        _scroll_speed = 1 * scroll_speed
