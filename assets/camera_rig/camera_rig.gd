extends Node3D
class_name CameraRig

var MathUtils = load("res://scripts/math_utils.gd")
const BodyEvents = preload("res://events/body.gd")
const CameraEvents = preload("res://events/camera.gd")


# Parameters

@export var debug: bool = false
@export var top_view: bool = false

@export_group("Dependencies")
@export var TranslationRig: Node3D
@export var RotationRig: Node3D
@export var Camera: Camera3D
@export var Target: Marker3D
@export var Heading: Node3D
@export var Audio: AudioStreamPlayer3D

@export_group("Controller Dynamics")

@export_subgroup("Movement")
@export_range(1.0, 20.0, 0.1) var max_impulse: float = 5.0
@export_range(1.0, 20.0, 0.1) var acceleration: float = 10.0
@export_range(0.0, 30.0, 0.1) var damping: float = 15.0
@export var speed_scaling: Curve

@export_subgroup("Zoom")
@export_range(1.0, 10.0, 0.1) var zoom_step: float = 7.5
@export_range(0.0, 10.0, 0.1) var zoom_damping: float = 2.0
@export_range(1.0, 10.0, 0.1) var zoom_speed: float = 2.0
@export_range(0.0, 10.0, 1.0) var min_altitude: float = 5.0
@export_range(0.0, 300.0, 1.0) var max_altitude: float = 50.0
@export var zoom_scaling: Curve

@export_subgroup("Rotation")
@export_range(0.001, 0.1, 0.001) var max_rotation_speed: float = 0.01
@export_range(0.01, 0.5, 0.01) var max_key_rotation_speed: float = 0.1
@export_range(0.0, 20.0, 0.1) var rotation_damping: float = 10.0

@export_subgroup("Heading")
@export_range(1.0, 20.0, 0.1) var heading_rotation_speed: float = 0.1


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

## Flags
var _is_panning: bool = false
var _is_rotation_locked: bool = false
var _is_traversing: bool = false

## Traversal
var _traversal_target: Vector3
var _traversal_vector: Vector3
var _theta: float
var _heading_debug: Vector3


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

var _height_ratio: float:
    get:
        return Camera.transform.origin.y / max_altitude

# Methods

func _ready() -> void:
    EventBus.service().subscribe(Events.BODY_SELECTED, self, "_on_body_selected")

    if top_view:
        Camera.projection = Camera3D.PROJECTION_ORTHOGONAL

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
    _calculate_heading()

    if not Heading.visible and _velocity.length() > 0.1:
        Heading.visible = true
    if Heading.visible and _velocity.length() <= 0.1:
        Heading.visible = false

    if not Audio.playing and (_velocity.length() > 0.1):
        Audio.play()
    if Audio.playing and (_velocity.length() <= 0.1):
        Audio.stop()

func _physics_process(delta: float) -> void:
    if not _is_traversing:
        _update_velocity_step(delta)
        _update_position_step(delta)

    else:
        _update_velocity_step(delta)
        _update_traversal(delta)

    _update_heading_rotation(delta)
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
    if _target_position.length() > 0.005:
        var impulse_mod = speed_scaling.sample(_height_ratio)
        _impulse = lerpf(_impulse, max_impulse * impulse_mod, delta * acceleration)
        translate(_target_position * _impulse * delta)
    else:
        _impulse = lerpf(_impulse, 0, delta * acceleration)
        _velocity = _velocity.lerp(Vector3.ZERO, delta * damping)
        _origin += _velocity * delta

    _target_position = Vector3.ZERO
    _target_altitude = Vector3.ZERO

func _update_rotation_step(delta: float) -> void:
    var start: Quaternion = _rotation_basis.get_rotation_quaternion().normalized()
    var end: Quaternion = _target_rotation.normalized()
    var result: Quaternion = start.slerp(end, delta * rotation_damping)
    _rotation_basis = Basis(result.normalized())

func _update_traversal(delta: float) -> void:
    _traversal_vector = _traversal_target - global_position
    var remaining_distance = _traversal_vector.length()

    if remaining_distance > 0.005:
        _impulse = lerpf(_impulse, max_impulse, delta * acceleration)
        translate(_traversal_vector * _impulse * delta)

    else:
        global_position = _traversal_target
        _traversal_target = Vector3.ZERO
        _origin = global_position
        _last_position = global_position
        _velocity = Vector3.ZERO
        _impulse = 0.0
        _is_traversing = false

    _traversal_vector = Vector3.ZERO

func _update_camera_altitude(delta: float) -> void:
    var start_y: float = Camera.transform.origin.y
    var y_pos: float = lerpf(start_y, _target_zoom, delta * zoom_speed * zoom_damping)
    var end: Vector3 = Vector3(Camera.transform.origin.x, y_pos, Camera.transform.origin.z)

    var _transform: Transform3D = Camera.transform

    _transform.origin = end
    Camera.transform = _transform
    Camera.look_at(Target.global_transform.origin, Vector3.UP)

func _update_heading_rotation(delta: float) -> void:
    Heading.rotation.y += clamp(heading_rotation_speed * delta, 0, abs(_theta)) * sign(_theta)

func _set_target_zoom(value: float) -> void:
    var step_mod = zoom_scaling.sample(_height_ratio)
    _target_zoom = Camera.transform.origin.y + value * (zoom_step * step_mod)
    _target_zoom = clampf(_target_zoom, min_altitude, max_altitude)

    var altitude_changed_event = CameraEvents.CameraAltitudeChangedEvent.new(
        _target_zoom,
        min_altitude,
        max_altitude,
    )

    EventBus.service().broadcast(altitude_changed_event)

func _calculate_heading() -> void:
    var a = position
    var direction = (position + _velocity) - a
    if direction:
        _theta = wrapf(atan2(direction.x, direction.z) - Heading.rotation.y, -PI, PI)

func _on_body_selected(event: BodyEvents.BodySelectedEvent) -> void:
    _traversal_target = event.position
    _is_traversing = true

func _draw_debug() -> void:
    DebugDraw3D.draw_line(global_position, global_position + _velocity, Color(0, 0, 1, 1))

    DebugDraw3D.draw_position(Transform3D(Basis(), _origin), Color(1, 0, 1, 1))
    DebugDraw3D.draw_position(Transform3D(Basis(), _last_position), Color(1, 1, 0, 1))

    var a = position
    var diff = (position + _velocity) - a
    var dist = diff.length()

    var text = ""

    if is_zero_approx(dist):
        text = "%1.2v" % Vector3.ZERO
    else:
        var t = Transform3D(Basis.looking_at(diff, Vector3.UP), a)
        text = "%1.2v" % t.basis.get_euler()

    var text_pos = global_position + Vector3.ONE
    DebugDraw3D.draw_text(text_pos, text)

    text_pos = Vector3(
        global_position.x - 1,
        global_position.y + 1,
        global_position.z - 1,
    )

    DebugDraw3D.draw_text(text_pos, "%1.2f" % _heading_debug.y)
