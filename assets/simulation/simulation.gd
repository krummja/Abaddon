class_name Simulation
extends Node3D

@export var body_count: int = 10
@export var body_scene: PackedScene

var _params: Array[BodyParameters] = []

func _ready():
    parameterize()

    for i in range(0, body_count):
        var body_param = _params[i]
        var body: Body = body_scene.instantiate()
        body.position = body_param.position
        # body.pos = body_param.position
        # body.vel = body_param.velocity
        # body.acc = Vector3.ONE * body_param.acceleration
        body.name = "%d" % i
        add_child(body)

func parameterize() -> void:
    for i in range(0, body_count):
        var a = randf() * TAU
        var pos_sin = sin(a)
        var pos_cos = cos(a)

        var r_values = []
        for j in range(0, 6):
            r_values.append(randf())
        var r0 = r_values.reduce(func(accum, elem): return accum + elem, 0)
        var r1 = abs(r0 / 3.0 - 1.0)
        var pos = Vector3(pos_cos, 0, pos_sin) * sqrt(body_count) * 10 * r1
        var vel = Vector3(pos_sin, 0, -pos_cos)
        _params.append(BodyParameters.new(pos, vel, r1, 1.0))

    _params.sort_custom(_sort_bodies)
    for i in range(0, body_count):
        var v = sqrt(i / _params[i].position.length())
        _params[i].velocity *= v

# func _process(_delta: float) -> void:
#     for i in range(0, len(_params)):
#         var p1 = _params[i].position
#         for j in range(0, len(_params)):
#             if j != i:
#                 var p2 = _params[j].position
#                 var m2 = _params[j].mass

#                 var r = p2 - p1
#                 var mag_sq = r.x + r.y * r.y
#                 var mag = sqrt(mag_sq)
#                 var a1 = (m2 / (mag_sq * mag)) * r
#                 _params[i].acceleration += a1

func _sort_bodies(a: BodyParameters, b: BodyParameters) -> bool:
    if a.position.length_squared() > b.position.length_squared():
        return true
    return false
