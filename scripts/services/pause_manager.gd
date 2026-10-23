extends Node

var _reasons: Dictionary = {}

func add_reason(reason: String) -> void:
    _reasons[reason] = true
    _apply()

func remove_reason(reason: String) -> void:
    _reasons.erase(reason)
    _apply()

func _apply() -> void:
    get_tree().paused = not _reasons.is_empty()

func is_paused() -> bool:
    return not _reasons.is_empty()