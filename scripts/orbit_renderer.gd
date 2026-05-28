extends MeshInstance3D

const CameraEvents = preload("res://events/camera.gd")

@export var radius: float = 10
@export_range(0.05, 0.1, 0.01) var width: float = 0.1

var _mesh: TorusMesh

func _ready() -> void:
    mesh = mesh.duplicate(true)
    _mesh = mesh

    _mesh.outer_radius = radius
    _mesh.inner_radius = radius - width

    EventBus.service().subscribe(Events.CAMERA_ALTITUDE_CHANGED, self, "_on_camera_altitude_changed")

func _on_camera_altitude_changed(event: CameraEvents.CameraAltitudeChangedEvent) -> void:
    var _material: StandardMaterial3D = _mesh.material
    var amount = remap(event.amount, event.min_zoom, event.max_zoom, 0.0, 0.1)
    _material.grow_amount = amount
