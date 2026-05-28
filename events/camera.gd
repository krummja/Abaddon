class CameraAltitudeChangedEvent extends Event:
    var amount: float
    var min_zoom: float
    var max_zoom: float

    const ID = Events.CAMERA_ALTITUDE_CHANGED

    func _init(amount_: float, min_: float, max_: float) -> void:
        super(ID)
        amount = amount_
        min_zoom = min_
        max_zoom = max_
