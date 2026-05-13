extends MeshInstance3D
class_name GridSection

var _mesh: PlaneMesh = mesh as PlaneMesh

var _size: int = 100
var size: int:
    get:
        return _size
    set(value):
        _size = value
        _mesh.size.x = value
        _mesh.size.y = value

func update_shader(x: float, y: float) -> void:
    set_instance_shader_parameter("centerOffset", Vector3(x, 0, y))
