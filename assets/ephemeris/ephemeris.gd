class_name Ephemeris
extends Node

@onready var http := $HTTPRequest

@export_category("Ephemeris Parameters")

@export_subgroup("UTC Date")
@export_range(2000, 4000) var ephemeris_year: int = 2000
@export var ephemeris_month: Time.Month = Time.MONTH_JANUARY
@export_range(1, 31) var ephemeris_day: int = 1

@export_subgroup("UTC Time")
@export_range(0, 23) var ephemeris_hour: int = 0
@export_range(0, 59) var ephemeris_minute: int = 0
@export_range(0, 59) var ephemeris_second: int = 0

@export_category("")

func _ready():
    http.set_tls_options(TLSOptions.client_unsafe())
