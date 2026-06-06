class_name DataLoader
extends Node

static func load_data_file(file_path: String) -> Array:
    var file = FileAccess.open(file_path, FileAccess.READ)
    var content = file.get_as_text()
    var json = JSON.new()
    var error = json.parse(content)

    if error == OK:
        var loaded = json.data
        if typeof(loaded) == TYPE_ARRAY:
            return loaded
        else:
            print("Unexpected data")
            return []
    else:
        print("JSON Parse Error: ", json.get_error_message())
        return []
