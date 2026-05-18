class_name NBodySimulation
extends Node3D

@export var debug: bool = false
@export var debug_bodies: bool = false

@export_category("Setup Parameters")
@export var generative: bool = true
@export var count_bodies: int = 100

@export_category("Simulation Parameters")
@export var gravity: float = 10.0
@export var time_multiplier: float = 1.0
@export var theta: float = 0.5

@export_category("References")
@export var body_scene: PackedScene

var _max_distance = 100
var _next_center = Vector3(0, 0, 0)

func _ready() -> void:
    if debug_bodies:
        for child in get_children():
            if "debug" in child:
                child.debug = debug

func _process(_delta: float) -> void:
    if debug:
        _debug_draw()

func _physics_process(delta: float) -> void:
    _simulation_step(delta)

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
        octree.prepare_debug()
        print(octree.debug_str)

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

func _debug_draw() -> void:
    var star = get_child(0)

    for body in get_children():
        if body.name == "Star":
            continue

        DebugDraw3D.draw_line(star.position, body.position)
        var midpoint = body.position / 2
        var length = star.position.distance_to(body.position)
        DebugDraw3D.draw_text(midpoint + Vector3(0, 1, 0), "%1.2f" % length)

func _debug_draw_octree(octree: OctreeNode) -> void:
    var debug_nodes = [octree]
    for node in octree.nodes:
        debug_nodes.append(node)

    for debug_node in debug_nodes:
        DebugDraw3D.draw_aabb(debug_node.bounds)
        DebugDraw3D.draw_sphere(debug_node.center_of_mass)
