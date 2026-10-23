extends Node

var money: int = 0
var current_order_index: int = 0
var current_order: Dictionary = {}
var placements: Dictionary = {} # category -> component id
var dirt_remaining: int = 0
var dirt_total: int = 0
var stage: String = "clean" # clean, diagnose, install, test, done
var language: String = "ru"

func reset_order(order: Dictionary) -> void:
    current_order = order
    placements.clear()
    dirt_total = int(order.get("dirt", 10))
    dirt_remaining = dirt_total
    stage = "clean"