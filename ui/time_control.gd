class_name TimeControl
extends PanelContainer

@export var paused: bool = true

@export var play_button: Button
@export var pause_button: Button
@export var slower_button: Button
@export var faster_button: Button

func _ready() -> void:
    play_button.pressed.connect(_play_pressed)
    pause_button.pressed.connect(_pause_pressed)
    slower_button.pressed.connect(_slower_pressed)
    faster_button.pressed.connect(_faster_pressed)

    if paused:
        _pause_pressed()
    else:
        _play_pressed()

func _play_pressed() -> void:
    play_button.disabled = true
    pause_button.disabled = false
    slower_button.disabled = false
    faster_button.disabled = false
    paused = false

    var event = Event.new(Events.TIME_CONTROL_PLAY_PRESSED)
    EventBus.service().broadcast(event)

func _pause_pressed() -> void:
    pause_button.disabled = true
    slower_button.disabled = true
    faster_button.disabled = true
    play_button.disabled = false
    paused = true

    var event = Event.new(Events.TIME_CONTROL_PAUSE_PRESSED)
    EventBus.service().broadcast(event)

func _slower_pressed() -> void:
    var event = Event.new(Events.TIME_CONTROL_SLOWER_PRESSED)
    EventBus.service().broadcast(event)

func _faster_pressed() -> void:
    var event = Event.new(Events.TIME_CONTROL_FASTER_PRESSED)
    EventBus.service().broadcast(event)
