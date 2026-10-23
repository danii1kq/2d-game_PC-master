extends Node

func _ready() -> void:
    var orders = OrderService.orders
    var bad := 0
    for o in orders:
        if not _has_solution(o):
            bad += 1
            print("NO SOLUTION: ", o.get("id"))
    if bad == 0:
        print("ECONOMY TEST PASS: all orders solvable")
    else:
        print("ECONOMY TEST FAIL: ", bad)
    # generated orders count
    print("Total orders: ", orders.size())
    await get_tree().create_timer(0.5).timeout
    get_tree().quit()

func _has_solution(order: Dictionary) -> bool:
    var budget := int(order.get("budget", 0))
    var cpu_opts = OrderService.components.filter(func(c): return c.get("category")=="cpu")
    var gpu_opts = OrderService.components.filter(func(c): return c.get("category")=="gpu")
    var ram_opts = OrderService.components.filter(func(c): return c.get("category")=="ram")
    var cool_opts = OrderService.components.filter(func(c): return c.get("category")=="cooling")
    for cpu in cpu_opts:
        for gpu in gpu_opts:
            for ram in ram_opts:
                for cool in cool_opts:
                    var placements = {"cpu":cpu.get("id"),"gpu":gpu.get("id"),"ram":ram.get("id"),"cooling":cool.get("id")}
                    var total = int(cpu.get("price",0))+int(gpu.get("price",0))+int(ram.get("price",0))+int(cool.get("price",0))
                    if total > budget:
                        continue
                    var res = EconomyService.check_requirements(order, placements)
                    if res.get("ok", false):
                        return true
    return false