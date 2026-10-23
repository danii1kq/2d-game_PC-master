extends Control

@onready var title: Label = $VBox/Title
@onready var grid: GridContainer = $VBox/Grid
@onready var back_button: Button = $VBox/BackButton

var colors := [
    Color(0.2,0.6,0.9), Color(0.6,0.3,0.8), Color(0.9,0.5,0.2), Color(0.3,0.8,0.4),
    Color(0.9,0.2,0.3), Color(0.2,0.8,0.8), Color(0.8,0.8,0.2), Color(0.5,0.5,0.9),
    Color(0.9,0.4,0.7), Color(0.4,0.9,0.6), Color(0.7,0.7,0.7), Color(0.1,0.1,0.1)
]

func _ready() -> void:
    back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))
    _update_language()
    for i in colors.size():
        var p := PanelContainer.new()
        p.custom_minimum_size = Vector2(96, 96)
        var rect := ColorRect.new()
        rect.color = colors[i]
        rect.custom_minimum_size = Vector2(80, 80)
        p.add_child(rect)
        var lbl := Label.new()
        lbl.text = "PC %d" % (i + 1)
        lbl.horizontal_alignment = 1
        p.add_child(lbl)
        grid.add_child(p)

func _update_language() -> void:
    title.text = "Витрина ПК" if GameState.language == "ru" else "PC Showcase"
    back_button.text = "Назад" if GameState.language == "ru" else "Back"