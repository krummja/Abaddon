class_name OctreeNode
extends RefCounted

var bounds: AABB
var mass: float = 0.0
var center_of_mass: Vector3 = Vector3.ZERO

var _body: Body
var _nodes: Array[OctreeNode] = []
var debug_str: String = ""

var body: Body:
    get: return _body

var nodes: Array[OctreeNode]:
    get: return _nodes

func _init(node_bounds: AABB = AABB(Vector3(), Vector3.ONE)) -> void:
    bounds = node_bounds
    center_of_mass = bounds.position + bounds.size / 2

func is_external_node() -> bool:
    return !(len(_nodes) > 0)

func add_body(new_body: Node3D) -> void:
    # Accumulate mass
    var current_mass = mass
    mass += new_body.mass

    # Calculate the new center of mass
    center_of_mass = (center_of_mass * current_mass + new_body.global_position * new_body.mass) / mass

    # If subnodes exist, add the body to the corresponding node
    if len(_nodes) > 0:
        for node in _nodes:
            if node.bounds.has_point(new_body.global_position):
                node.add_body(new_body)
                return

    # If no other body present, add the new body to this node
    elif _body == null:
        _body = new_body

    # If there is already a body present, create subnodes and add the bodies
    else:
        _create_subnodes()

        for b in [_body, new_body]:
            for node in _nodes:
                if node.bounds.has_point(b.global_position):
                    node.add_body(b)
                    break

        _body = null

func prepare_debug(indent: String = "") -> void:
    debug_str = indent + str(self) + "\n"
    debug_str += indent + "mass %d" % mass + "\n"
    debug_str += indent + "bounds %s" % bounds + "\n"
    debug_str += indent + "body %s" % _body + "\n"

    for n in nodes:
        n.prepare_debug(indent + "-")

func _create_subnodes() -> void:
    var half_size = bounds.size / 2
    var half_size_x = Vector3(half_size.x, 0, 0)
    var half_size_y = Vector3(0, half_size.y, 0)
    var half_size_z = Vector3(0, 0, half_size.z)

    # Create eight subnodes
    _nodes.append(get_script().new(AABB(bounds.position + half_size, half_size)))
    _nodes.append(get_script().new(AABB(bounds.position + half_size_y + half_size_z, half_size)))
    _nodes.append(get_script().new(AABB(bounds.position + half_size_z, half_size)))
    _nodes.append(get_script().new(AABB(bounds.position + half_size_x + half_size_z, half_size)))
    _nodes.append(get_script().new(AABB(bounds.position + half_size_x + half_size_y, half_size)))
    _nodes.append(get_script().new(AABB(bounds.position + half_size_y, half_size)))
    _nodes.append(get_script().new(AABB(bounds.position + half_size_x, half_size)))
    _nodes.append(get_script().new(AABB(bounds.position, half_size)))
