extends Node

var money: int = 0
var current_order_index: int = 0
var current_order: Dictionary = {}
var placements: Dictionary = {}
var dirt_remaining: int = 0
var dirt_total: int = 0
var stage: String = "clean"
var language: String = "ru"
var workshop_stage: int = 0
var assistant_level: int = 0
var last_save_time: float = 0.0
var personal_pc_parts: Array = []

func _ready() -> void:
    call_deferred("_load_save")

func _load_save() -> void:
    var data := SaveService.load_state()
    if data.is_empty():
        return
    money = int(data.get("money", money))
    current_order_index = int(data.get("order_index", current_order_index))
    language = str(data.get("language", language))
    workshop_stage = int(data.get("workshop_stage", workshop_stage))
    assistant_level = int(data.get("assistant_level", assistant_level))
    personal_pc_parts = data.get("personal_pc_parts", personal_pc_parts)
    var saved_time := float(data.get("last_save_time", 0.0))
    if assistant_level > 0 and saved_time > 0.0:
        var elapsed := Time.get_unix_time_from_system() - saved_time
        elapsed = clamp(elapsed, 0.0, 7200.0)
        var income := int(elapsed / 60.0) * (5 * assistant_level)
        money += income
    last_save_time = Time.get_unix_time_from_system()

func reset_order(order: Dictionary) -> void:
    current_order = order
    placements.clear()
    dirt_total = int(order.get("dirt", 10))
    dirt_remaining = dirt_total
    stage = "clean"