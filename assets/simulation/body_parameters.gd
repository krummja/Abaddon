class_name BodyParameters
extends Resource

var _pos: Vector3
var _vel: Vector3
var _mass: float
var _r: float
var _a: Vector3

var position: Vector3:
    get: return _pos
    set(value):
        _pos = value

var velocity: Vector3:
    get: return _vel
    set(value):
        _vel = value

var radius: float:
    get: return _r
    set(value):
        _r = value

var mass: float:
    get: return _mass
    set(value):
        _mass = value

var acceleration: Vector3:
    get: return _a
    set(value):
        _a = value

func _init(pos: Vector3, vel: Vector3, m: float):
    _pos = pos
    _vel = vel
    _mass = m
