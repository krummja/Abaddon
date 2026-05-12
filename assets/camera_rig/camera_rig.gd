extends Node3D
class_name CameraRig

var MathUtils = load("res://scripts/math_utils.gd")

# Parameters

@export var debug: bool = false

@export_group("Dependencies")

@export var TranslationRig: Node3D
@export var RotationRig: Node3D
@export var Camera: Camera3D
@export var Target: Marker3D

@export_group("Controller Dynamics")

@export_subgroup("Movement")

@export var max_impulse: float = 5.0
@export var acceleration: float = 10.0
@export var damping: float = 15.0
@export var vertical_damping: float = 5.0

@export_subgroup("Zoom")

## How far the camera moves on each scroll step
@export var zoom_step: float = 7.5

## How snappy the zoom is - lower value is more sluggish, higher is faster
@export var zoom_damping: float = 7.5

## How quickly the camera moves during the zoom
@export var zoom_speed: float = 2.0

@export var min_altitude: float = 5.0
@export var max_altitude: float = 50.0

@export_subgroup("Rotation")

@export var max_rotation_speed: float = 0.01
@export var max_key_rotation_speed: float = 0.1
@export var rotation_damping: float = 10.0


# Variables

## Mouse Panning

var _pan_start: Vector2
var _pan_delta: Vector2
var _pan_stop: Vector2

## Translation

var _velocity: Vector3
var _last_position: Vector3
var _target_position: Vector3

## Zoom

var _target_altitude: Vector3

## Rotation

var _target_rotation: Quaternion

## Motion Dynamics

var _impulse: float
var _target_zoom: float
var _motion_modifier: float

## Flags

var _is_panning: bool = false
var _is_rotation_locked: bool = false
var _is_traversing: bool = false

## Traversal

var _traversal_steps: Array[Vector3]


# Properties

var _origin: Vector3:
    get:
        return self.transform.origin
    set(value):
        var _transform: Transform3D = self.transform
        _transform.origin = value
        self.transform = _transform

var _rotation_basis: Basis:
    get:
        return RotationRig.transform.basis
    set(value):
        var _transform: Transform3D = RotationRig.transform
        _transform.basis = value
        RotationRig.transform = _transform


# Methods

func _ready() -> void:
    Camera.look_at(Target.global_transform.origin, Vector3.UP)
    _last_position = _origin
    _target_rotation = transform.basis.get_rotation_quaternion()
    _target_zoom = clampf(Camera.transform.origin.y, min_altitude, max_altitude)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        match event.button_index:
            MOUSE_BUTTON_LEFT:
                if not _is_panning and event.pressed:
                    _pan_start = event.position
                    _is_panning = true
                if _is_panning and not event.pressed:
                    _pan_stop = event.position
                    _is_panning = false

            MOUSE_BUTTON_RIGHT:
                if not _is_rotation_locked and event.pressed:
                    _is_rotation_locked = true
                if _is_rotation_locked and not event.pressed:
                    _is_rotation_locked = false

    if event is InputEventMouseMotion:
        if _is_rotation_locked:
            var value = event.relative.x * -1
            if absf(value) > 0.1:
                var y_euler = _rotation_basis.get_euler().y
                _target_rotation = Quaternion(Vector3.UP, value * max_rotation_speed + y_euler)

func _process(delta: float) -> void:
    _get_mouse_pan_input()
    _get_keyboard_input()
    _get_scroll_wheel_input(delta)

    if not _is_traversing:
        _update_velocity_step(delta)
        _update_position_step(delta)
    else:
        _update_traversal(delta)

    _update_rotation_step(delta)
    _update_camera_altitude(delta)

    if debug:
        _draw_debug()


# Local Methods

func _get_keyboard_input() -> void:
    var keyboard_input: Vector3 = Vector3(0, 0, 0)
    var axis_rotation: float = 0.0

    if Input.is_action_pressed("forward"):
        keyboard_input.z = -1
    if Input.is_action_pressed("left"):
        keyboard_input.x = -1
    if Input.is_action_pressed("back"):
        keyboard_input.z = 1
    if Input.is_action_pressed("right"):
        keyboard_input.x = 1
    if Input.is_action_pressed("up"):
        keyboard_input.y = 1
    if Input.is_action_pressed("down"):
        keyboard_input.y = -1

    if Input.is_action_pressed("rot_left"):
        axis_rotation = 1
    if Input.is_action_pressed("rot_right"):
        axis_rotation = -1

    keyboard_input = keyboard_input.normalized()

    if keyboard_input.length_squared() > 0.1:
        _target_position += keyboard_input * 5.0
        _target_position.y *= 0.85
        _target_position = _target_position.rotated(Vector3.UP, _rotation_basis.get_euler().y)

    if abs(axis_rotation) > 0.1:
        var y_euler = _rotation_basis.get_euler().y
        var _target = axis_rotation * max_key_rotation_speed + y_euler
        _target_rotation = Quaternion(Vector3.UP, _target)

func _get_mouse_pan_input() -> void:
    if not _is_panning:
        _target_position = Vector3.ZERO
        return

    _pan_stop = get_viewport().get_mouse_position()
    _pan_delta = (_pan_start - _pan_stop) / 50
    _pan_delta = MathUtils.Vector2Clamp(_pan_delta, -10, 10)

    if Input.is_key_pressed(Key.KEY_CTRL):
        _target_position = Vector3.UP * _pan_delta.y
    else:
        _target_position = Vector3(_pan_delta.x, 0, _pan_delta.y) * -1
        _target_position = _target_position.rotated(Vector3.UP, _rotation_basis.get_euler().y)

func _get_scroll_wheel_input(delta: float) -> void:
    if Input.is_action_just_pressed("wheel_down"):
        _set_target_zoom(100 * delta)
    if Input.is_action_just_pressed("wheel_up"):
        _set_target_zoom(-100 * delta)

func _update_velocity_step(delta: float) -> void:
    _velocity = (_origin - _last_position) / delta
    _last_position = _origin

func _update_position_step(delta: float) -> void:
    if _target_position.length() > 0.1:
        _impulse = lerpf(_impulse, max_impulse, delta * acceleration)
        translate(_target_position * _impulse * delta)
    else:
        _velocity = _velocity.lerp(Vector3.ZERO, delta * damping)
        _origin += _velocity * delta

    _target_position = Vector3.ZERO
    _target_altitude = Vector3.ZERO

func _update_rotation_step(delta: float) -> void:
    var start: Quaternion = _rotation_basis.get_rotation_quaternion().normalized()
    var end: Quaternion = _target_rotation.normalized()
    var result: Quaternion = start.slerp(end, delta * rotation_damping)
    _rotation_basis = Basis(result)

func _update_traversal(_delta: float) -> void:
    if len(_traversal_steps) > 0:
        var next_step = _traversal_steps.pop_back()
        translate(next_step)
    else:
        _velocity = Vector3.ZERO
        _target_position = Vector3.ZERO
        _last_position = _origin
        _is_traversing = false

func _update_camera_altitude(delta: float) -> void:
    var start_y: float = Camera.transform.origin.y
    var y_pos: float = lerpf(start_y, _target_zoom, delta * zoom_speed * zoom_damping)
    var end: Vector3 = Vector3(Camera.transform.origin.x, y_pos, Camera.transform.origin.z)

    var _transform: Transform3D = Camera.transform

    _transform.origin = end
    Camera.transform = _transform
    Camera.look_at(Target.global_transform.origin, Vector3.UP)

func _set_target_zoom(value: float) -> void:
    _target_zoom = Camera.transform.origin.y + value * zoom_step
    _target_zoom = clampf(_target_zoom, min_altitude, max_altitude)

func _draw_debug() -> void:
    pass
