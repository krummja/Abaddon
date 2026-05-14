class_name Body
extends Node3D

@export var body_visual: PackedScene
@export var parameters: BodyParameters

var pos: Vector3
var vel: Vector3
var acc: Vector3

func _ready():
    pos = Vector3.ZERO
    vel = Vector3.ZERO
    acc = Vector3.ZERO

# func _physics_process(delta) -> void:
#     pos += vel * delta
#     vel += acc * delta
#     acc = Vector3.ZERO
