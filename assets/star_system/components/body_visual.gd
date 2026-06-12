class_name BodyVisual
extends MeshInstance3D

var parent_body: SystemBody
var color: Color
var radius: float

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

func _init(p_parent: SystemBody, p_color: Color, p_radius: float) -> void:
    Debug.debug("BEGIN BodyVisual for %s" % p_parent.name)

    name = "%s BodyVisual" % p_parent.name

    parent_body = p_parent
    color = p_color
    radius = p_radius

    Debug.debug("  END BodyVisual for %s" % parent_body.name)

func _ready() -> void:
    Debug.debug("BEGIN BodyVisual for %s" % parent_body.name)

    if body_mesh == null:
        body_mesh = SphereMesh.new()
        body_mesh.radius = radius
        body_mesh.height = radius * 2.0

    if body_material == null:
        body_material = StandardMaterial3D.new()
        body_material.emission_enabled = true
        body_material.emission = color

    Debug.debug("  END BodyVisual for %s" % parent_body.name)

# func _physics_process(_delta: float) -> void:
#     var a = parent_body.semi_major_axis
#     var e = parent_body.eccentricity
#     var v = parent_body.true_anomaly

#     var r = (a * (1 - pow(e, 2))) / (1 + e * cos(v))
#     var x = r * cos(v)
#     var y = r * sin(v)

#     position.x = -x * Constants.DISTANCE_SCALE_FACTOR
#     position.z = y * Constants.DISTANCE_SCALE_FACTOR
