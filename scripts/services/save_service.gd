extends Node

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 2

func save_state(state: Dictionary) -> void:
    var payload := state.duplicate()
    payload["version"] = SAVE_VERSION
    payload["revision"] = int(payload.get("revision", 0)) + 1
    payload["timestamp"] = Time.get_unix_time_from_system()
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(payload))
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
    var data = json.data
    if typeof(data) != TYPE_DICTIONARY:
        return {}
    # migration: accept v1 without version
    if not data.has("version"):
        data["version"] = 1
    return data