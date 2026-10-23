extends Control

@onready var play_button: Button = $Center/Panel/VBox/PlayButton
@onready var showcase_button: Button = $Center/Panel/VBox/ShowcaseButton
@onready var language_button: Button = $Center/Panel/VBox/LanguageButton
@onready var quit_button: Button = $Center/Panel/VBox/QuitButton
@onready var title: Label = $Center/Panel/VBox/Title
@onready var subtitle: Label = $Center/Panel/VBox/Subtitle
@onready var desc: Label = $Center/Panel/VBox/Desc

func _ready() -> void:
    for b in [play_button, showcase_button, language_button, quit_button]:
        UITheme.style_button(b)
        b.pivot_offset = b.size / 2.0
        b.mouse_entered.connect(func(): _tween_scale(b, 1.05))
        b.mouse_exited.connect(func(): _tween_scale(b, 1.0))
    UITheme.style_panel($Center/Panel)
    play_button.pressed.connect(_on_play)
    showcase_button.pressed.connect(_on_showcase)
    language_button.pressed.connect(_on_language)
    quit_button.pressed.connect(_on_quit)
    _update_language()
    # fade in
    modulate.a = 0.0
    var tw := create_tween()
    tw.tween_property(self, "modulate:a", 1.0, 0.4)

func _tween_scale(btn: Button, s: float) -> void:
    var tw := create_tween()
    tw.tween_property(btn, "scale", Vector2(s, s), 0.12)

func _on_play() -> void:
    get_tree().change_scene_to_file("res://scenes/workshop/workshop.tscn")

func _on_showcase() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/showcase.tscn")

func _on_language() -> void:
    GameState.language = "en" if GameState.language == "ru" else "ru"
    SaveService.save_state({"money": GameState.money, "order_index": GameState.current_order_index, "language": GameState.language, "workshop_stage": GameState.workshop_stage})
    _update_language()

func _update_language() -> void:
    if GameState.language == "ru":
        title.text = "ПК-мастер"
        subtitle.text = "Из хлама в топ"
        desc.text = "Чистите, чините и улучшайте компьютеры. Развивайте мастерскую."
        play_button.text = "Играть"
        showcase_button.text = "Витрина ПК"
        language_button.text = "Язык: RU"
        quit_button.text = "Выход"
    else:
        title.text = "PC Master"
        subtitle.text = "Scrap to Top"
        desc.text = "Clean, repair and upgrade computers. Grow your workshop."
        play_button.text = "Play"
        showcase_button.text = "PC Showcase"
        language_button.text = "Language: EN"
        quit_button.text = "Quit"

func _on_quit() -> void:
    get_tree().quit()