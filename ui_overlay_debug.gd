extends Control

@onready var label := $MarginContainer/Label

func _ready():
    label.text = "Overlay"
