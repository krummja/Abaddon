class_name BodyManager
extends Node3D

@export var body_scene: PackedScene
@export var body_count: int = 1000

var body_parameters: Dictionary[int, BodyParameters] = {}:
    get: return body_parameters

var body_map: Dictionary[int, NodePath] = {}:
    get: return body_map

var _body_parameters: Array[BodyParameters] = []

func generate() -> void:
    print("Generating...")
    _initialize_parameters()
    _body_parameters.sort_custom(_sort_bodies)
    _initialize_velocities()
    _cache_parameters()
    print("Done! Total Bodies: %d" % len(_body_parameters))

func reset() -> void:
    print("Resetting...")
    _body_parameters = []
    body_parameters = {}
    body_map = {}
    print("Done! Body parameters cleared (Count: %d)" % len(_body_parameters))

func build(simulation: Simulation) -> void:
    print("Instantiating %d Body Objects..." % body_count)
    for i in range(body_count):
        var parameters = body_parameters[i]
        var body: Body = body_scene.instantiate()
        body.position = parameters.position
        body.name = "%d" % i

        simulation.add_child(body)

        body.add_to_group("bodies")
        body_map[i] = body.get_path()
    print("Done!")

func _initialize_parameters() -> void:
    for i in range(body_count):
        _body_parameters.append(_rand_body())

    var vel = (
        _body_parameters
        .map(func(a): return a.velocity * a.mass)
        .reduce(func(a, b): return a + b, Vector3.ZERO)
    ) / body_count

    var pos = (
        _body_parameters
        .map(func(a): return a.position * a.mass)
        .reduce(func(a, b): return a + b, Vector3.ZERO)
    ) / body_count

    for param in _body_parameters:
        param.velocity -= vel
        param.position -= pos

    var r = (
        _body_parameters
        .map(func(a): return a.position.length())
        .max()
    )

    for param in _body_parameters:
        param.position /= r

func _initialize_velocities() -> void:
    for i in range(0, body_count):
        var v = sqrt(i / _body_parameters[i].position.length())
        _body_parameters[i].velocity *= v

func _cache_parameters() -> void:
    for i in range(len(_body_parameters)):
        var parameter = _body_parameters[i]
        body_parameters[i] = parameter

func _sort_bodies(a: BodyParameters, b: BodyParameters) -> bool:
    if a.position.length_squared() > b.position.length_squared():
        return true
    return false

func _rand_body() -> BodyParameters:
    var pos = _rand_disc()
    var vel = _rand_disc()
    return BodyParameters.new(pos, vel, 1.0)

func _rand_disc() -> Vector3:
    var theta = randf() * TAU
    return Vector3(cos(theta), 0.0, sin(theta) * randf())
