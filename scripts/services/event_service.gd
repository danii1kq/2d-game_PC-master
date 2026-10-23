extends Node

const LOG_PATH := "user://events.log"

func log_event(event_name: String, data: Dictionary = {}) -> void:
    var f := FileAccess.open(LOG_PATH, FileAccess.READ_WRITE)
    if f == null:
        f = FileAccess.open(LOG_PATH, FileAccess.WRITE)
    if f:
        f.seek_end()
        f.store_line(JSON.stringify({"event": event_name, "data": data, "time": Time.get_unix_time_from_system()}))
        f.close()