extends Control

@onready var Root: VBoxContainer = $Root
@onready var Top: HBoxContainer = $Root/Top
@onready var Main: HBoxContainer = $Root/Main
@onready var Left: VBoxContainer = $Root/Main/Left
@onready var Center: VBoxContainer = $Root/Main/Center
@onready var Panel_CenterTop: Panel = $Root/Main/Center/Top
@onready var View: MarginContainer = $Root/Main/Center/View
@onready var Panel_CenterBottom: Panel = $Root/Main/Center/Bottom
@onready var Right: VBoxContainer = $Root/Main/Right
@onready var Bottom: HBoxContainer = $Root/Bottom

func _ready():
    pass
