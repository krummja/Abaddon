class BodySelectedEvent extends Event:
    var position: Vector3

    const ID = Events.BODY_SELECTED

    func _init(p_position: Vector3) -> void:
        super(ID)
        position = p_position


class BodyHoveredEvent extends Event:
    var world_position: Vector3
    var screen_position: Vector2

    const ID = Events.BODY_HOVERED

    func _init(p_world_position: Vector3, p_screen_position: Vector2) -> void:
        super(ID)
        screen_position = p_screen_position
        world_position = p_world_position
