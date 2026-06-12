class_name SystemBody
extends Node3D

const OrbitSolver = preload("res://scripts/orbit_solver.gd")
const OrbitEvents = preload("res://assets/star_system/events/orbit.gd")

@export var debug: bool = false

@export_category("Body Information")
@export var body_name: String = "<UNSET>"
@export_file("*.json") var data_file: String

@export_category("Visual Parameters")

@export_category("Kepler Elements")
@export_custom(Constants.NOHINT, "suffix:au", Constants.READONLY) var epoch: String
@export_custom(Constants.NOHINT, "suffix:au", Constants.READONLY) var semi_major_axis: float
@export_custom(Constants.NOHINT, "suffix:au", Constants.READONLY) var semi_minor_axis: float
@export_custom(Constants.NOHINT, "suffix:e", Constants.READONLY) var eccentricity: float
@export_custom(Constants.NOHINT, "suffix:deg", Constants.READONLY) var inclination: float
@export_custom(Constants.NOHINT, "suffix:deg", Constants.READONLY) var longitude_of_the_ascending_node: float
@export_custom(Constants.NOHINT, "suffix:au", Constants.READONLY) var longitude_of_the_perifocus: float
@export_custom(Constants.NOHINT, "suffix:deg", Constants.READONLY) var argument_of_the_perifocus: float
@export_custom(Constants.NOHINT, "suffix:deg/d", Constants.READONLY) var mean_motion: float
@export_custom(Constants.NOHINT, "suffix:deg", Constants.READONLY) var mean_anomaly: float
@export_custom(Constants.NOHINT, "suffix:deg", Constants.READONLY) var true_anomaly: float
@export_custom(Constants.NOHINT, "suffix:deg", Constants.READONLY) var eccentric_anomaly: float
@export_custom(Constants.NOHINT, "suffix:au", Constants.READONLY) var apoapsis_distance: float
@export_custom(Constants.NOHINT, "suffix:au", Constants.READONLY) var periapsis_distance: float
@export_custom(Constants.NOHINT, "suffix:au", Constants.READONLY) var perifocus_distance: float
@export_custom(Constants.NOHINT, "suffix:d", Constants.READONLY) var orbital_period: float

var _children: Array[SystemBody] = []

var body_parent: SystemBody:
    get:
        var _parent = get_parent()
        if _parent is SystemBody:
            return _parent as SystemBody
        return self

var body_children: Array[SystemBody]:
    get:
        return _children

func is_system_root() -> bool:
    return body_parent == self

func has_children() -> bool:
    return len(body_children) > 0

func setup() -> void:
    pass

func load_data() -> void:
    if data_file:
        var data = DataLoader.load_data_file(data_file)
        var elements = data[1]
        _initialize_elements(elements)

func _ready() -> void:
    Debug.debug("BEGIN SystemBody %s (%s)" % [name, body_name])

    position = body_parent.position

    for child in get_children():
        if child is SystemBody:
            _children.push_back(child)

    load_data()
    setup()

    Debug.debug("  END SystemBody %s (%s)" % [name, body_name])

func _process(_delta: float) -> void:
    if debug:
        _draw_debug()

func _initialize_elements(data: Dictionary) -> void:
    body_name = data["targetname"]
    epoch = "JDN %.1f" % data["datetime_jd"]
    eccentricity = data["e"]
    inclination = data["incl"]
    longitude_of_the_ascending_node = data["Omega"]
    argument_of_the_perifocus = data["w"]
    mean_motion = data["n"]
    mean_anomaly = data["M"]
    true_anomaly = data["nu"]
    semi_major_axis = data["a"]
    apoapsis_distance = data["Q"]
    periapsis_distance = data["q"]
    orbital_period = data["P"]

    semi_minor_axis = semi_major_axis * sqrt(abs(1 - pow(eccentricity, 2)))
    longitude_of_the_perifocus = longitude_of_the_ascending_node + argument_of_the_perifocus
    eccentric_anomaly =  OrbitSolver.calculate_eccentric_anomaly(eccentricity, mean_anomaly)

func _draw_debug() -> void:
    DebugDraw3D.draw_text(global_position, body_name, 32)
