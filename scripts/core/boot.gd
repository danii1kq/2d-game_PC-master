extends Control

func _ready() -> void:
    # Minimal boot: go to main menu.
    await get_tree().create_timer(0.2).timeout
    get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")