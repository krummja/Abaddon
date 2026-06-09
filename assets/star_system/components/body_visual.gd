class_name BodyVisual
extends MeshInstance3D

@export var color: Color
@export var radius: float

var body_mesh: SphereMesh:
    get:
        return mesh
    set(value):
        mesh = value

var body_material: Material:
    get:
        return body_mesh.material
    set(value):
        body_mesh.material = value

func _ready() -> void:
    if body_mesh == null:
        body_mesh = SphereMesh.new()
        body_mesh.radius = radius
        body_mesh.height = radius * 2.0

    if body_material == null:
        body_material = StandardMaterial3D.new()
        body_material.emission_enabled = true
        body_material.emission = color
