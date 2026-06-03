class_name Simulation
extends Node3D

@export var min_distance: float = 0.01
@export var debug: bool = false
@export var modifier: float = 1.0

@onready var body_manager: BodyManager = $BodyManager

func _ready() -> void:
    body_manager.generate()
    body_manager.build(self)

func _process(delta: float) -> void:
    for i in range(body_manager.body_count):
        var b1 = body_manager.body_parameters[i]

        var p1 = b1.position
        var m1 = b1.mass

        for j in range(i+1, body_manager.body_count):
            var b2 = body_manager.body_parameters[j]

            var p2 = b2.position
            var m2 = b2.mass

            var r = p2 - p1
            var mag_sq = r.x * r.x + r.y * r.y
            var mag = sqrt(mag_sq)
            var tmp = r / (maxf(mag_sq, min_distance ) * mag)
            b1.acceleration += m2 * tmp
            b2.acceleration -= m1 * tmp

        var body_path = body_manager.body_map[i]
        var body: Body = get_node(body_path)

        # Update the actual body
        body.position = b1.position

        # Update parameters for the next step
        b1.position += b1.velocity * delta * modifier
        b1.velocity += b1.acceleration * delta * modifier
        b1.acceleration = Vector3.ZERO

    if debug:
        _draw_debug()

func _draw_debug() -> void:
    for i in range(body_manager.body_count):
        var body = body_manager.body_parameters[i]
        DebugDraw3D.draw_line(body.position, body.position + body.velocity)

        var pos = Vector3(
            body.position.x + 0.5,
            body.position.y + 0.5,
            body.position.z + 0.5,
        )
        DebugDraw3D.draw_text(pos, "%1.2v" % body.position)
