
class LeapSecondsRequestedEvent extends Event:
    var leap_seconds: int

    const ID = Events.TIME_LEAP_SECONDS_REQUESTED

    func _init(p_leap_seconds: int) -> void:
        super(ID)
        leap_seconds = p_leap_seconds
