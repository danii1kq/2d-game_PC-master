extends Control

@onready var order_title: Label = $RootVBox/TopBar/OrderTitle
@onready var money_label: Label = $RootVBox/TopBar/MoneyLabel
@onready var client_name: Label = $RootVBox/Middle/ClientPanel/ClientVBox/ClientName
@onready var client_avatar: ColorRect = $RootVBox/Middle/ClientPanel/ClientVBox/ClientAvatar
@onready var client_story: Label = $RootVBox/Middle/ClientPanel/ClientVBox/ClientStory
@onready var requirements: Label = $RootVBox/Middle/ClientPanel/ClientVBox/Requirements
@onready var budget_label: Label = $RootVBox/Middle/ClientPanel/ClientVBox/Budget
@onready var dirt_container: Control = $RootVBox/Middle/PCPanel/PCVBox/DirtContainer
@onready var benchmark_bar: ProgressBar = $RootVBox/Middle/PCPanel/PCVBox/BenchmarkBar
@onready var cpu_slot: Button = $RootVBox/Middle/PCPanel/PCVBox/Slots/CPUSlot
@onready var gpu_slot: Button = $RootVBox/Middle/PCPanel/PCVBox/Slots/GPUSlot
@onready var ram_slot: Button = $RootVBox/Middle/PCPanel/PCVBox/Slots/RAMSlot
@onready var cool_slot: Button = $RootVBox/Middle/PCPanel/PCVBox/Slots/CoolSlot
@onready var cpu_option: OptionButton = $RootVBox/Middle/ComponentsPanel/CompVBox/CPUOption
@onready var gpu_option: OptionButton = $RootVBox/Middle/ComponentsPanel/CompVBox/GPUOption
@onready var ram_option: OptionButton = $RootVBox/Middle/ComponentsPanel/CompVBox/RAMOption
@onready var cool_option: OptionButton = $RootVBox/Middle/ComponentsPanel/CompVBox/CoolOption
@onready var install_hint: Label = $RootVBox/Middle/ComponentsPanel/CompVBox/InstallHint
@onready var test_button: Button = $RootVBox/Bottom/TestButton
@onready var next_button: Button = $RootVBox/Bottom/NextButton
@onready var upgrade_button: Button = $RootVBox/Bottom/UpgradeButton
@onready var ad_button: Button = $RootVBox/Bottom/AdButton
@onready var status_label: Label = $RootVBox/Bottom/StatusLabel
@onready var pc_panel: PanelContainer = $RootVBox/Middle/PCPanel

var _dirt_nodes: Array = []
var _benchmarking := false

func _ready() -> void:
    test_button.pressed.connect(_on_test)
    next_button.pressed.connect(_on_next)
    upgrade_button.pressed.connect(_on_upgrade)
    ad_button.pressed.connect(_on_ad)
    cpu_option.item_selected.connect(func(i): _select_component("cpu", i))
    gpu_option.item_selected.connect(func(i): _select_component("gpu", i))
    ram_option.item_selected.connect(func(i): _select_component("ram", i))
    cool_option.item_selected.connect(func(i): _select_component("cooling", i))
    cpu_slot.pressed.connect(func(): _clear_slot("cpu"))
    gpu_slot.pressed.connect(func(): _clear_slot("gpu"))
    ram_slot.pressed.connect(func(): _clear_slot("ram"))
    cool_slot.pressed.connect(func(): _clear_slot("cooling"))
    _start_order()

func _start_order() -> void:
    var order := OrderService.get_order(GameState.current_order_index)
    if order.is_empty():
        order_title.text = "Все заказы выполнены!" if GameState.language == "ru" else "All orders complete!"
        status_label.text = "Поздравляем" if GameState.language == "ru" else "Congratulations"
        test_button.disabled = true
        next_button.disabled = true
        return
    GameState.reset_order(order)
    _populate_options()
    _create_dirt()
    _update_ui()
    EventService.log_event("order_start", {"order_id": order.get("id")})

func _populate_options() -> void:
    _fill_option(cpu_option, "cpu")
    _fill_option(gpu_option, "gpu")
    _fill_option(ram_option, "ram")
    _fill_option(cool_option, "cooling")

func _fill_option(opt: OptionButton, category: String) -> void:
    opt.clear()
    opt.add_item("—", -1)
    for c in OrderService.components:
        if c.get("category") == category:
            var label := str(c.get("name_ru" if GameState.language == "ru" else "name_en"))
            opt.add_item("%s — %d" % [label, int(c.get("price", 0))], int(c.get("tier", 0)))

func _select_component(category: String, index: int) -> void:
    if index <= 0:
        GameState.placements.erase(category)
    else:
        var comps := []
        for c in OrderService.components:
            if c.get("category") == category:
                comps.append(c)
        if index - 1 < comps.size():
            GameState.placements[category] = comps[index - 1].get("id")
    _update_ui()

func _clear_slot(category: String) -> void:
    GameState.placements.erase(category)
    # reset option selection
    match category:
        "cpu": cpu_option.select(0)
        "gpu": gpu_option.select(0)
        "ram": ram_option.select(0)
        "cooling": cool_option.select(0)
    _update_ui()

func _create_dirt() -> void:
    for n in _dirt_nodes:
        n.queue_free()
    _dirt_nodes.clear()
    var total := GameState.dirt_total
    var cols := 6
    for i in total:
        var spot := ColorRect.new()
        spot.color = Color(0.55, 0.45, 0.3, 0.85)
        spot.custom_minimum_size = Vector2(26, 26)
        spot.size = Vector2(26, 26)
        spot.position = Vector2((i % cols) * 34 + 6, int(i / cols) * 34 + 6)
        spot.mouse_filter = Control.MOUSE_FILTER_STOP
        spot.gui_input.connect(_on_dirt_input.bind(spot))
        dirt_container.add_child(spot)
        _dirt_nodes.append(spot)

func _on_dirt_input(event: InputEvent, spot: ColorRect) -> void:
    if event is InputEventMouseButton or event is InputEventMouseMotion:
        if spot in _dirt_nodes:
            _dirt_nodes.erase(spot)
            spot.queue_free()
            GameState.dirt_remaining = max(0, GameState.dirt_remaining - 1)
            var threshold := maxi(1, int(ceil(GameState.dirt_total * 0.05)))
            if GameState.dirt_remaining <= threshold:
                for s in _dirt_nodes.duplicate():
                    s.queue_free()
                    _dirt_nodes.erase(s)
                GameState.dirt_remaining = 0
            _update_ui()

func _update_ui() -> void:
    var order := GameState.current_order
    var client := StoryService.get_client(GameState.current_order_index)
    var cname := str(client.get("name_ru" if GameState.language == "ru" else "name_en", ""))
    client_name.text = cname
    var av := str(client.get("avatar", "0.4,0.4,0.6")).split(",")
    if av.size() == 3:
        client_avatar.color = Color(float(av[0]), float(av[1]), float(av[2]))
    client_story.text = str(client.get("story_ru" if GameState.language == "ru" else "story_en", ""))
    var req_text := "Требования: " if GameState.language == "ru" else "Requirements: "
    var reqs: Array = order.get("requirements", [])
    var parts := []
    for r in reqs:
        parts.append(_req_text(r))
    requirements.text = req_text + ", ".join(parts)
    var total_price := 0
    for cat in GameState.placements:
        total_price += int(OrderService.get_component(GameState.placements[cat]).get("price", 0))
    var budget := int(order.get("budget", 0))
    budget_label.text = ("Бюджет: %d / %d" % [total_price, budget]) if GameState.language == "ru" else ("Budget: %d / %d" % [total_price, budget])
    money_label.text = ("Монеты: %d" % GameState.money) if GameState.language == "ru" else ("Coins: %d" % GameState.money)
    order_title.text = ("Заказ: %s" % str(order.get("client_ru" if GameState.language == "ru" else "client_en", ""))) if not order.is_empty() else ("Готово" if GameState.language == "ru" else "Done")
    # slots
    cpu_slot.text = _slot_text("cpu", "CPU")
    gpu_slot.text = _slot_text("gpu", "GPU")
    ram_slot.text = _slot_text("ram", "RAM")
    cool_slot.text = _slot_text("cooling", "Cooling")
    var dirt_pct := 0
    if GameState.dirt_total > 0:
        dirt_pct = int(100.0 * (GameState.dirt_total - GameState.dirt_remaining) / GameState.dirt_total)
    status_label.text = ("Очистка: %d%% | Мастерская %d/3" % [dirt_pct, GameState.workshop_stage + 1]) if GameState.language == "ru" else ("Cleaning: %d%% | Workshop %d/3" % [dirt_pct, GameState.workshop_stage + 1])
    var stage_colors := [Color(0.25,0.25,0.3), Color(0.3,0.25,0.4), Color(0.25,0.35,0.45)]
    pc_panel.modulate = stage_colors[clamp(GameState.workshop_stage, 0, 2)]
    install_hint.text = "Выберите деталь, затем слот" if GameState.language == "ru" else "Choose a part, then a slot"

func _req_text(r: Dictionary) -> String:
    var t := str(r.get("type"))
    var v := int(r.get("value", 0))
    match t:
        "cpu_min": return ("CPU ≥ %d" % v)
        "gpu_min": return ("GPU ≥ %d" % v)
        "ram_min": return ("RAM ≥ %d" % v)
        "cooling_min_heat": return ("Охлаждение ≥ тепло" if GameState.language == "ru" else "Cooling ≥ heat")
    return t

func _slot_text(category: String, label: String) -> String:
    if GameState.placements.has(category):
        var c := OrderService.get_component(GameState.placements[category])
        return "%s: %s" % [label, str(c.get("name_ru" if GameState.language == "ru" else "name_en"))]
    return "%s: %s" % [label, "пусто" if GameState.language == "ru" else "empty"]

func _on_test() -> void:
    if _benchmarking:
        return
    var order := GameState.current_order
    if GameState.dirt_remaining > 0:
        status_label.text = "Сначала очистите системник" if GameState.language == "ru" else "Clean the PC first"
        return
    var res := EconomyService.check_requirements(order, GameState.placements)
    if not res.get("ok", false):
        status_label.text = str(res.get("reason", "Ошибка"))
        return
    if not EconomyService.budget_ok(order, GameState.placements):
        status_label.text = "Превышен бюджет клиента" if GameState.language == "ru" else "Client budget exceeded"
        return
    # benchmark
    _benchmarking = true
    test_button.disabled = true
    next_button.disabled = true
    benchmark_bar.value = 0
    var steps := 40
    for i in steps:
        await get_tree().create_timer(0.08).timeout
        benchmark_bar.value = (i + 1) * 100.0 / steps
    _benchmarking = false
    GameState.money += int(order.get("reward", 0))
    GameState.stage = "done"
    status_label.text = ("Тест пройден! +%d монет" % int(order.get("reward", 0))) if GameState.language == "ru" else ("Test passed! +%d coins" % int(order.get("reward", 0)))
    benchmark_bar.value = 100
    EventService.log_event("order_complete", {"order_id": order.get("id"), "reward": order.get("reward")})
    _save()
    test_button.disabled = false
    next_button.disabled = false

func _on_next() -> void:
    if _benchmarking:
        return
    # mock interstitial
    await AdService.show_interstitial()
    GameState.current_order_index += 1
    _start_order()

func _on_upgrade() -> void:
    var costs := [150, 300, 600]
    var idx := GameState.workshop_stage
    if idx >= costs.size():
        status_label.text = "Максимальный уровень" if GameState.language == "ru" else "Max level"
        return
    if GameState.money < costs[idx]:
        status_label.text = "Недостаточно монет" if GameState.language == "ru" else "Not enough coins"
        return
    GameState.money -= costs[idx]
    GameState.workshop_stage += 1
    status_label.text = "Мастерская улучшена" if GameState.language == "ru" else "Workshop upgraded"
    EventService.log_event("upgrade_purchased", {"stage": GameState.workshop_stage})
    _update_ui()
    _save()

func _on_ad() -> void:
    ad_button.disabled = true
    var amount := 120
    AdService.rewarded_granted.connect(func(a): GameState.money += a; status_label.text = ("Реклама: +%d монет" % a) if GameState.language=="ru" else ("Ad: +%d coins" % a); _update_ui(); _save(), CONNECT_ONE_SHOT)
    await AdService.show_rewarded(amount)
    ad_button.disabled = false

func _save() -> void:
    SaveService.save_state({
        "money": GameState.money,
        "order_index": GameState.current_order_index,
        "language": GameState.language,
        "workshop_stage": GameState.workshop_stage
    })