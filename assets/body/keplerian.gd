class_name Keplerian
extends Node3D

@export_category("Orbital Parameters")
@export var apoapsis: float = 10.0
@export var periapsis: float = 3.0
@export var epoch: float = 0.0

@export_category("Orbital Characteristics")
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var eccentricity: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_major_axis: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_minor_axis: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var semi_parameter: float
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT) var center_point: Vector3

@export_category("Dependencies")
@export var body: Body
@export var orbit: Orbit

func _ready():
    orbit.apoapsis = apoapsis
    orbit.periapsis = periapsis
