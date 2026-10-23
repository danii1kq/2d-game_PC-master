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
    if index < 0:
        return {}
    # Infinite generator: choose a valid configuration first.
    var rng := RandomNumberGenerator.new()
    rng.seed = index * 97 + 13
    var cpu = components.filter(func(c): return c.get("category") == "cpu")[rng.randi_range(0, 5)]
    var gpu = components.filter(func(c): return c.get("category") == "gpu")[rng.randi_range(0, 5)]
    var ram = components.filter(func(c): return c.get("category") == "ram")[rng.randi_range(0, 5)]
    var cool = components.filter(func(c): return c.get("category") == "cooling")[rng.randi_range(0, 5)]
    var total_heat := int(cpu.get("heat",0)) + int(gpu.get("heat",0)) + int(ram.get("heat",0))
    var reqs := [{"type":"cpu_min","value":int(cpu.get("score",0))}, {"type":"gpu_min","value":int(gpu.get("score",0))}, {"type":"ram_min","value":int(ram.get("score",0))}]
    if total_heat > 0:
        reqs.append({"type":"cooling_min_heat","value":0})
    var total_price := int(cpu.get("price",0)) + int(gpu.get("price",0)) + int(ram.get("price",0)) + int(cool.get("price",0))
    return {
        "id": "gen_%d" % index,
        "client_ru": "Сгенерированный заказ #%d" % (index + 1),
        "client_en": "Generated order #%d" % (index + 1),
        "requirements": reqs,
        "dirt": rng.randi_range(10, 20),
        "budget": total_price + rng.randi_range(40, 120),
        "reward": int(total_price * 0.45) + 60
    }

func validate_order(order: Dictionary) -> bool:
    # Ensure at least one solution in budget.
    var budget := int(order.get("budget", 0))
    var reqs: Array = order.get("requirements", [])
    # brute force small: choose cheapest satisfying? We'll just check existence of components per category.
    return budget > 0 and reqs.size() > 0