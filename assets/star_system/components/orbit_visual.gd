class_name OrbitVisual
extends MeshInstance3D

const OrbitEvents = preload("res://assets/star_system/events/orbit.gd")

var parent_body: SystemBody

var orbit_mesh: ImmediateMesh:
    get:
        return mesh
    set(value):
        mesh = value

var orbit_material: Material:
    get:
        return orbit_mesh.material
    set(value):
        orbit_mesh.material = value

var focus_offset: Vector3:
    get:
        var a = parent_body.semi_major_axis * Constants.DISTANCE_SCALE_FACTOR
        var b = parent_body.semi_minor_axis * Constants.DISTANCE_SCALE_FACTOR
        var c = sqrt(pow(a, 2) - pow(b, 2))
        return Vector3(c, 0, 0)

func _init(p_parent: SystemBody) -> void:
    parent_body = p_parent

    EventBus.service().subscribe(
        OrbitEvents.ELEMENTS_CALCULATED,
        self,
        "_on_elements_calculated",
    )

    Debug.debug("OrbitVisual for %s" % parent_body.name)

func _on_elements_calculated(_event: OrbitEvents.ElementsCalculatedEvent) -> void:
    if orbit_mesh == null:
        pass
