class_name SystemBody
extends Node3D

@export var debug: bool = false

@export_category("Body Information")
@export var body_name: String = "<UNSET>"

@export_category("Visual Parameters")

@export_category("Kepler Elements")
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var epoch: String
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_major_axis: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_minor_axis: float
@export_custom(PROPERTY_HINT_NONE, "suffix:e", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eccentricity: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var inclination: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var longitude_of_the_ascending_node: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var longitude_of_the_perifocus: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var argument_of_the_perifocus: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg/d", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var mean_motion: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var mean_anomaly: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var true_anomaly: float
@export_custom(PROPERTY_HINT_NONE, "suffix:deg", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eccentric_anomaly: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var apoapsis_distance: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var periapsis_distance: float
@export_custom(PROPERTY_HINT_NONE, "suffix:au", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var perifocus_distance: float
@export_custom(PROPERTY_HINT_NONE, "suffix:d", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var orbital_period: float

var body_parent: SystemBody:
    get:
        var _parent = get_parent()
        if _parent is SystemBody:
            return _parent as SystemBody
        return self

var body_children: Array[SystemBody]:
    get:
        var _children: Array[SystemBody] = []
        for child in get_children():
            if child is SystemBody:
                _children.push_back(child)
        return _children

func is_system_root() -> bool:
    return body_parent == self

func has_children() -> bool:
    return len(body_children) > 0

func _ready() -> void:
    pass

func _process(_delta: float) -> void:
    print("System")
    if debug:
        _draw_debug()

func _draw_debug() -> void:
    DebugDraw3D.draw_text(global_position, body_name, 32)
