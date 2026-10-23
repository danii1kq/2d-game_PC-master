extends Control

@onready var play_button: Button = $VBox/PlayButton
@onready var language_button: Button = $VBox/LanguageButton
@onready var quit_button: Button = $VBox/QuitButton

func _ready() -> void:
    play_button.pressed.connect(_on_play)
    language_button.pressed.connect(_on_language)
    quit_button.pressed.connect(_on_quit)
    _update_language()

func _on_play() -> void:
    get_tree().change_scene_to_file("res://scenes/workshop/workshop.tscn")

func _on_language() -> void:
    GameState.language = "en" if GameState.language == "ru" else "ru"
    SaveService.save_state({"money": GameState.money, "order_index": GameState.current_order_index, "language": GameState.language})
    _update_language()

func _update_language() -> void:
    if GameState.language == "ru":
        $VBox/Title.text = "ПК-мастер: из хлама в топ"
        play_button.text = "Играть"
        language_button.text = "Язык: RU"
        quit_button.text = "Выход"
    else:
        $VBox/Title.text = "PC Master: Scrap to Top"
        play_button.text = "Play"
        language_button.text = "Language: EN"
        quit_button.text = "Quit"

func _on_quit() -> void:
    get_tree().quit()