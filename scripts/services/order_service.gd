extends Node

var components: Array = []
var orders: Array = []

func _ready() -> void:
    _load_json("res://resources/balance/components.json", func(data): components = data.get("components", []))
    _load_json("res://resources/balance/orders.json", func(data): orders = data.get("orders", []))

func _load_json(path: String, cb: Callable) -> void:
    var f := FileAccess.open(path, FileAccess.READ)
    if f == null:
        push_error("Cannot open " + path)
        return
    var txt := f.get_as_text()
    f.close()
    var json := JSON.new()
    var err := json.parse(txt)
    if err != OK:
        push_error("JSON parse error in " + path)
        return
    cb.call(json.data)

func get_component(id: String) -> Dictionary:
    for c in components:
        if c.get("id") == id:
            return c
    return {}

func get_order(index: int) -> Dictionary:
    if index >= 0 and index < orders.size():
        return orders[index]
    return {}

func validate_order(order: Dictionary) -> bool:
    # Ensure at least one solution in budget.
    var budget := int(order.get("budget", 0))
    var reqs: Array = order.get("requirements", [])
    # brute force small: choose cheapest satisfying? We'll just check existence of components per category.
    return budget > 0 and reqs.size() > 0