extends CanvasLayer

@export var camera_rig: CameraRig

@export var translation_label: Label
@export var rotation_label: Label
@export var zoom_label: Label

func _ready():
    camera_rig.position_changed.connect(_on_position_changed)
    camera_rig.rotation_changed.connect(_on_rotation_changed)
    camera_rig.zoom_changed.connect(_on_zoom_changed)

func _on_position_changed(value: Vector3) -> void:
    var label_template = "(%s, %s, %s)"
    var interpolated = label_template & [value.x, value.y, value.z]
    translation_label.text = interpolated

func _on_rotation_changed(value: Quaternion) -> void:
    var label_template = "(%s, %s, %s, %s)"
    var interpolated = label_template % [value.x, value.y, value.z, value.w]
    rotation_label.text = interpolated

func _on_zoom_changed(value: float) -> void:
    zoom_label.text = str(snapped(value, 0.01))
