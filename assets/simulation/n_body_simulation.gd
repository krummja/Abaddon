class_name NBodySimulation
extends Node3D

@export var debug: bool = false
@export var debug_bodies: bool = false

@export_category("Setup Parameters")
@export var prewarm: bool = true
@export var prewarm_duration: int = 2
@export var prewarm_multiplier: float = 10.0

@export_category("Simulation Parameters")
@export var gravity: float = 10.0
@export var time_multiplier: float = 1.0
@export var max_time_multiplier: float = 10.0
@export var theta: float = 0.5

@export_category("References")
@export var body_scene: PackedScene

var _max_distance = 100
var _next_center = Vector3(0, 0, 0)
var _last_multiplier: float

func _ready() -> void:
    EventBus.service().subscribe(Events.TIME_CONTROL_PLAY_PRESSED, self, "_on_time_control_play_pressed")
    EventBus.service().subscribe(Events.TIME_CONTROL_PAUSE_PRESSED, self, "_on_time_control_pause_pressed")
    EventBus.service().subscribe(Events.TIME_CONTROL_SLOWER_PRESSED, self, "_on_time_control_slower_pressed")
    EventBus.service().subscribe(Events.TIME_CONTROL_FASTER_PRESSED, self, "_on_time_control_faster_pressed")

    _last_multiplier = time_multiplier

    if debug_bodies:
        for child in get_children():
            if "debug" in child:
                child.debug = debug

    # _run_prewarm(0.0)

func _on_time_control_play_pressed(_event: Event) -> void:
    time_multiplier = _last_multiplier

func _on_time_control_pause_pressed(_event: Event) -> void:
    _last_multiplier = time_multiplier
    time_multiplier = 0.0

func _on_time_control_slower_pressed(_event: Event) -> void:
    time_multiplier = max(0.0, time_multiplier - 0.5)

func _on_time_control_faster_pressed(_event: Event) -> void:
    time_multiplier = min(max_time_multiplier, time_multiplier + 0.5)

func _physics_process(delta: float) -> void:
    _simulation_step(delta)

func _run_prewarm(delta: float) -> void:
    var _cached_multiplier = time_multiplier
    time_multiplier = prewarm_multiplier

    for body in get_children():
        body.point_count *= prewarm_multiplier
        # body.point_rate /= prewarm_multiplier

    # var timer: SceneTreeTimer = get_tree().create_timer(prewarm_duration)
    # print(timer.time_left)
    # time_multiplier = _cached_multiplier

func _simulation_step(delta: float) -> void:
    var half_size = Vector3(_max_distance, _max_distance, _max_distance)
    var octree = OctreeNode.new(AABB(_next_center - half_size, half_size + half_size))

    _max_distance = 0

    for child in get_children():
        if "mass" in child and "velocity" in child:
            octree.add_body(child)

    for child in get_children():
        var force = _calculate_force(child, octree)
        child.velocity += force / child.mass * delta * time_multiplier
        child.position += child.velocity * delta * time_multiplier

        var distance_to_center = child.position - octree.center_of_mass
        _max_distance = max(_max_distance, abs(distance_to_center.x))
        _max_distance = max(_max_distance, abs(distance_to_center.y))
        _max_distance = max(_max_distance, abs(distance_to_center.z))

    _next_center = octree.center_of_mass
    _max_distance += 1

    if debug:
        _debug_draw_octree(octree)

func _calculate_force(body: Body, octree_node: OctreeNode) -> Vector3:
    var force = Vector3()

    # Calculate force from external nodes
    # Check if node doesn't contain body and is different than the one currently being
    # calculated
    if octree_node.is_external_node():
        if octree_node.body != null and octree_node.body != body:
            var distance = octree_node.center_of_mass - body.position
            var scalar_force = gravity * octree_node.mass / distance.length_squared()
            force = scalar_force * distance.normalized()

    else:
        var s = octree_node.bounds.size.x
        var d = octree_node.center_of_mass - body.position
        var ratio = s / d.length()

        if ratio < theta:
            # Node is far enough away, calculate force for whole node
            var scalar_force = gravity * octree_node.mass * body.mass / d.length_squared()
            force = scalar_force * d.normalized()

        else:
            # Node is near enough, calculate forces for subnodes
            for node in octree_node.nodes:
                force += _calculate_force(body, node)

    return force

func _debug_draw_octree(octree: OctreeNode) -> void:
    DebugDraw3D.draw_aabb(octree.bounds)
    DebugDraw3D.draw_position(Transform3D(Basis(), octree.center_of_mass))

    for node in octree.nodes:
        _debug_draw_octree(node)
