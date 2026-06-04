class_name PropertyList
extends VBoxContainer

@export var properties: Dictionary[String, PropertyBinding] = {}

var _cached_values: Dictionary[String, String] = {}

func _ready() -> void:
    for property_name in properties:
        var property = Property.new()
        property.name = property_name
        var binding = properties[property_name]

        var resolved_value = resolve_binding(binding)
        _cached_values[property_name] = "%s" % resolved_value

        property.property_label = property_name
        property.property_value = "value"
        property.property_value = _cached_values[property_name]
        add_child(property)

func _process(_delta: float) -> void:
    for property_name in properties:
        update_cached_value(property_name)
        var value = _cached_values[property_name]
        update_label_value(property_name, value)

func update_label_value(property_name: String, value: String) -> void:
    for child in get_children():
        if child.name == property_name:
            (child as Property).update_value(value)

func update_cached_value(property_name: String) -> void:
    var binding = properties[property_name]
    var resolved_value = resolve_binding(binding)
    var cached_value = _cached_values[property_name]
    if resolved_value != cached_value:
        _cached_values[property_name] = resolved_value

func resolve_binding(binding: PropertyBinding) -> String:
    var watched_object = get_node(binding.watched_node_path)

    var parts = binding.watched_node_property.split(".")
    var current = watched_object

    for part in parts:
        current = current[part]

    match typeof(current):
        TYPE_INT:
            return "%10d" % current
        TYPE_FLOAT:
            return "%10.2f" % current
        TYPE_VECTOR3:
            return "%5.2v" % current
        TYPE_VECTOR2:
            return "%5.2v" % current
        _:
            print("unusable variant")
            return ""
