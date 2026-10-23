extends Control

@onready var play_button: Button = $VBox/PlayButton
@onready var language_button: Button = $VBox/LanguageButton
@onready var quit_button: Button = $VBox/QuitButton

var _lang := "ru"

func _ready() -> void:
    play_button.pressed.connect(_on_play)
    language_button.pressed.connect(_on_language)
    quit_button.pressed.connect(_on_quit)
    _update_language()

func _on_play() -> void:
    get_tree().change_scene_to_file("res://scenes/workshop/workshop.tscn")

func _on_language() -> void:
    _lang = "en" if _lang == "ru" else "ru"
    _update_language()

func _update_language() -> void:
    language_button.text = "Language: " + _lang.to_upper() if _lang == "en" else "Язык: " + _lang.to_upper()
    # TODO: propagate to autoload localization

func _on_quit() -> void:
    get_tree().quit()