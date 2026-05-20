class_name EventSubscription
extends RefCounted

var event_id: String
var subscriber: Object
var function_name: String

func _init(id: String, sub: Object, func_name: String) -> void:
    event_id = id
    subscriber = sub
    function_name = func_name
