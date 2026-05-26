class BodySelectedEvent extends Event:
    var position: Vector3

    const ID = Events.BODY_SELECTED

    func _init(body_position: Vector3) -> void:
        super(ID)
        position = body_position


class BodyHoveredEvent extends Event:
    var position: Vector2

    const ID = Events.BODY_HOVERED

    func _init(screen_position: Vector2) -> void:
        super(ID)
        position = screen_position
