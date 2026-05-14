class_name BodyParameters
extends Resource

var _pos: Vector3
var _vel: Vector3
var _mass: float
var _r: float
var _a: float = 0.0

var position: Vector3:
    get: return _pos

var velocity: Vector3:
    get: return _vel

var radius: float:
    get: return _r

var mass: float:
    get: return _mass

var acceleration: float:
    get: return _a
    set(value):
        _a = value

func _init(pos: Vector3, vel: Vector3, r: float, m: float):
    _pos = pos
    _vel = vel
    _mass = m
    _r = r
