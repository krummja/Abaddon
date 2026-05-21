class_name KeyValue
extends HBoxContainer

@export var key: String
@export var default_value: String

@onready var KeyLabel: Label = $Key
@onready var ValueLabel: Label = $Value

func _ready():
    KeyLabel.text = key
    ValueLabel.text = default_value
