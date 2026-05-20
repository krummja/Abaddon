@tool
class_name Heading
extends Node3D

@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var velocity: Vector3 = Vector3.ZERO:
    set(new_velocity):
        velocity = new_velocity
        magnitude = velocity.length()

@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var magnitude: float

func _enter_tree() -> void:
    set_notify_transform(true)

func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSFORM_CHANGED:
        velocity = position
