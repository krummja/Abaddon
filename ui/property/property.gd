class_name Property
extends HBoxContainer

signal label_changed(new_label)
signal value_changed(new_value)

@export var property_label: String:
    set(value):
        label_changed.emit(value)
        property_label = value

@export var property_value: String:
    set(value):
        value_changed.emit(value)
        property_value = value

var _label: Label
var _value: Label

func _ready():
    _label = Label.new()
    _value = Label.new()
    add_child(_label)
    add_child(_value)

    _label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    _label.text = property_label
    _value.text = property_value

func update_value(new_value: String) -> void:
    _value.text = new_value
