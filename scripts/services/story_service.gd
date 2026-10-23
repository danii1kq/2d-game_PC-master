extends Node

var clients: Array = []

func _ready() -> void:
    var f := FileAccess.open("res://resources/story/clients.json", FileAccess.READ)
    if f:
        var j := JSON.new()
        if j.parse(f.get_as_text()) == OK:
            clients = j.data.get("clients", [])
        f.close()

func get_client(order_index: int) -> Dictionary:
    for c in clients:
        if int(c.get("order_index", -1)) == order_index:
            return c
    # generated fallback
    return {
        "name_ru": "Клиент #%d" % (order_index + 1),
        "name_en": "Client #%d" % (order_index + 1),
        "avatar": "0.4,0.4,0.6",
        "story_ru": "Новый заказ: собрать подходящую конфигурацию под бюджет.",
        "story_en": "New order: build a suitable configuration within budget."
    }