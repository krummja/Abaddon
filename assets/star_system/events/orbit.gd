
const ELEMENTS_CALCULATED = "ELEMENTS_CALCULATED"


class ElementsCalculatedEvent extends Event:
    const ID = ELEMENTS_CALCULATED
    func _init() -> void:
        super(ID)
