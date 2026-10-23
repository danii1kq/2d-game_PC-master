extends Node

const SAVE_PATH := "user://save.json"

func save_state(state: Dictionary) -> void:
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(state))
        f.close()

func load_state() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return {}
    var txt := f.get_as_text()
    f.close()
    var json := JSON.new()
    if json.parse(txt) != OK:
        return {}
    return json.data if typeof(json.data) == TYPE_DICTIONARY else {}