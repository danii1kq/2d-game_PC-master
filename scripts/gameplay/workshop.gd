extends Control

@onready var order_label: Label = $RootVBox/OrderLabel
@onready var budget_label: Label = $RootVBox/BudgetLabel
@onready var dirt_container: Control = $RootVBox/Middle/PCPanel/PCVBox/DirtContainer
@onready var cpu_option: OptionButton = $RootVBox/Middle/ComponentsPanel/CompVBox/CPUOption
@onready var gpu_option: OptionButton = $RootVBox/Middle/ComponentsPanel/CompVBox/GPUOption
@onready var ram_option: OptionButton = $RootVBox/Middle/ComponentsPanel/CompVBox/RAMOption
@onready var cool_option: OptionButton = $RootVBox/Middle/ComponentsPanel/CompVBox/CoolOption
@onready var test_button: Button = $RootVBox/Bottom/TestButton
@onready var next_button: Button = $RootVBox/Bottom/NextButton
@onready var upgrade_button: Button = $RootVBox/Bottom/UpgradeButton
@onready var ad_button: Button = $RootVBox/Bottom/AdButton
@onready var status_label: Label = $RootVBox/Bottom/StatusLabel
@onready var pc_panel: PanelContainer = $RootVBox/Middle/PCPanel

var _dirt_buttons: Array = []

func _ready() -> void:
    test_button.pressed.connect(_on_test)
    next_button.pressed.connect(_on_next)
    upgrade_button.pressed.connect(_on_upgrade)
    ad_button.pressed.connect(_on_ad)
    cpu_option.item_selected.connect(func(i): _on_component_selected("cpu", i))
    gpu_option.item_selected.connect(func(i): _on_component_selected("gpu", i))
    ram_option.item_selected.connect(func(i): _on_component_selected("ram", i))
    cool_option.item_selected.connect(func(i): _on_component_selected("cooling", i))
    _start_order()

func _start_order() -> void:
    var order := OrderService.get_order(GameState.current_order_index)
    if order.is_empty():
        order_label.text = "Все заказы выполнены! Поздравляем." if GameState.language == "ru" else "All orders complete! Congratulations."
        budget_label.text = "Монеты: %d" % GameState.money if GameState.language == "ru" else "Coins: %d" % GameState.money
        status_label.text = "Готово" if GameState.language == "ru" else "Done"
        next_button.disabled = true
        test_button.disabled = true
        return
    GameState.reset_order(order)
    _populate_options()
    _create_dirt()
    _update_ui()

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
            opt.add_item(label, int(c.get("tier", 0)))
    opt.select(0)

func _on_component_selected(category: String, index: int) -> void:
    if index <= 0:
        GameState.placements.erase(category)
    else:
        # find component by category + index-1
        var comps := []
        for c in OrderService.components:
            if c.get("category") == category:
                comps.append(c)
        if index - 1 < comps.size():
            GameState.placements[category] = comps[index - 1].get("id")
    _update_ui()

func _create_dirt() -> void:
    for b in _dirt_buttons:
        b.queue_free()
    _dirt_buttons.clear()
    var total := GameState.dirt_total
    var cols := 5
    for i in total:
        var btn := Button.new()
        btn.text = "•"
        btn.custom_minimum_size = Vector2(32, 32)
        var x := (i % cols) * 40 + 8
        var y := int(i / cols) * 40 + 8
        btn.position = Vector2(x, y)
        btn.pressed.connect(_on_dirt_pressed.bind(btn))
        dirt_container.add_child(btn)
        _dirt_buttons.append(btn)

func _on_dirt_pressed(btn: Button) -> void:
    if btn in _dirt_buttons:
        _dirt_buttons.erase(btn)
        btn.queue_free()
        GameState.dirt_remaining = max(0, GameState.dirt_remaining - 1)
        # auto-complete remaining when <= 5% (at least 1)
        var threshold := maxi(1, int(ceil(GameState.dirt_total * 0.05)))
        if GameState.dirt_remaining <= threshold:
            # remove all remaining
            for b in _dirt_buttons.duplicate():
                b.queue_free()
                _dirt_buttons.erase(b)
            GameState.dirt_remaining = 0
        _update_ui()

func _update_ui() -> void:
    var order := GameState.current_order
    var client := str(order.get("client_ru" if GameState.language == "ru" else "client_en", ""))
    order_label.text = client
    var total_price := 0
    for cat in GameState.placements:
        total_price += int(OrderService.get_component(GameState.placements[cat]).get("price", 0))
    var budget := int(order.get("budget", 0))
    budget_label.text = ("Бюджет: %d / %d   Монеты: %d" % [total_price, budget, GameState.money]) if GameState.language == "ru" else ("Budget: %d / %d   Coins: %d" % [total_price, budget, GameState.money])
    var dirt_pct := 0
    if GameState.dirt_total > 0:
        dirt_pct = int(100.0 * (GameState.dirt_total - GameState.dirt_remaining) / GameState.dirt_total)
    status_label.text = ("Очистка: %d%% | Мастерская: %d/3" % [dirt_pct, GameState.workshop_stage + 1]) if GameState.language == "ru" else ("Cleaning: %d%% | Workshop: %d/3" % [dirt_pct, GameState.workshop_stage + 1])
    var stage_colors := [Color(0.25,0.25,0.3), Color(0.3,0.25,0.4), Color(0.25,0.35,0.45)]
    pc_panel.modulate = stage_colors[clamp(GameState.workshop_stage, 0, 2)]

func _on_test() -> void:
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
    # success
    GameState.money += int(order.get("reward", 0))
    GameState.stage = "done"
    status_label.text = ("Тест пройден! +%d монет" % int(order.get("reward", 0))) if GameState.language == "ru" else ("Test passed! +%d coins" % int(order.get("reward", 0)))
    _save()

func _on_next() -> void:
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