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

func reset_order(order: Dictionary) -> void:
    current_order = order
    placements.clear()
    dirt_total = int(order.get("dirt", 10))
    dirt_remaining = dirt_total
    stage = "clean"