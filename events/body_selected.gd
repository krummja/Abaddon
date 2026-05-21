class BodySelectedEvent extends Event:
    var position: Vector3

    const ID = Events.BODY_SELECTED

    func _init(body_position: Vector3) -> void:
        super(ID)
        position = body_position
