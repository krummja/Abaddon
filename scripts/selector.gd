extends Node3D

const RAY_LENGTH = 10_000

@onready var ray: RayCast3D = $RayCast3D
@onready var camera: Camera3D = $Camera3D

func _physics_process(delta: float) -> void:
    if Input.is_action_pressed("LMB"):
        var mouse_pos = get_viewport().get_mouse_position()
        ray.global_position = camera.project_ray_origin(mouse_pos)
        ray.target_position = ray.global_position + camera.project_local_ray_normal(mouse_pos) * RAY_LENGTH
        ray.force_raycast_update()

        if ray.is_colliding():
            var collision_object = ray.get_collider()
            print(collision_object.name)
