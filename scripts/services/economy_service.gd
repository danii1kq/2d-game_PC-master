extends Node

func check_requirements(order: Dictionary, placements: Dictionary) -> Dictionary:
    # returns {ok:bool, reason:String}
    var reqs: Array = order.get("requirements", [])
    var total_heat := 0
    for cat in ["cpu","gpu","ram"]:
        if placements.has(cat):
            var c := OrderService.get_component(placements[cat])
            total_heat += int(c.get("heat", 0))
    for r in reqs:
        var t := str(r.get("type"))
        var val := int(r.get("value", 0))
        match t:
            "cpu_min":
                if not placements.has("cpu") or int(OrderService.get_component(placements["cpu"]).get("score",0)) < val:
                    return {"ok": false, "reason": "Нужен более мощный процессор" if GameState.language=="ru" else "Need a stronger CPU"}
            "gpu_min":
                if not placements.has("gpu") or int(OrderService.get_component(placements["gpu"]).get("score",0)) < val:
                    return {"ok": false, "reason": "Нужна более мощная видеокарта" if GameState.language=="ru" else "Need a stronger GPU"}
            "ram_min":
                if not placements.has("ram") or int(OrderService.get_component(placements["ram"]).get("score",0)) < val:
                    return {"ok": false, "reason": "Нужно больше памяти" if GameState.language=="ru" else "Need more memory"}
            "cooling_min_heat":
                if placements.has("cooling"):
                    var cool_score := int(OrderService.get_component(placements["cooling"]).get("score",0))
                    if cool_score < total_heat:
                        return {"ok": false, "reason": "Охлаждение слабее нагрузки" if GameState.language=="ru" else "Cooling is weaker than heat"}
                else:
                    if total_heat > 0:
                        return {"ok": false, "reason": "Нужно охлаждение" if GameState.language=="ru" else "Need cooling"}
    # cooling requirement if no explicit but heat
    if total_heat > 0 and not placements.has("cooling"):
        return {"ok": false, "reason": "Нужно охлаждение" if GameState.language=="ru" else "Need cooling"}
    if placements.has("cooling"):
        var cool_score2 := int(OrderService.get_component(placements["cooling"]).get("score",0))
        if cool_score2 < total_heat:
            return {"ok": false, "reason": "Охлаждение слабее нагрузки" if GameState.language=="ru" else "Cooling is weaker than heat"}
    return {"ok": true, "reason": "OK"}

func budget_ok(order: Dictionary, placements: Dictionary) -> bool:
    var total := 0
    for cat in placements:
        total += int(OrderService.get_component(placements[cat]).get("price",0))
    return total <= int(order.get("budget",0))