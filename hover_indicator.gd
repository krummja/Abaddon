extends CenterContainer

const BodyEvents = preload("res://events/body.gd")

@onready var indicator: TextureRect = $TextureRect

func _ready():
    pass
    # EventBus.service().subscribe(Events.BODY_HOVERED, self, "_on_body_hovered")

# func _on_body_hovered(event: BodyEvents.BodyHoveredEvent) -> void:
#     indicator.visible = true
#     var pos = Vector2(event.position.x - 50, event.position.y - 50)
#     position = pos
