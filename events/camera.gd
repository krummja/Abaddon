class CameraAltitudeChangedEvent extends Event:
    var amount: float
    var min_zoom: float
    var max_zoom: float

    const ID = Events.CAMERA_ALTITUDE_CHANGED

    func _init(p_amount: float, p_min: float, p_max: float) -> void:
        super(ID)
        amount = p_amount
        min_zoom = p_min
        max_zoom = p_max
