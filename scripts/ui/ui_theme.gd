extends Node

const BTN := "res://assets/kenney/ui-pack/PNG/Blue/Default/button_rectangle_depth_gloss.png"
const BTN_HOVER := "res://assets/kenney/ui-pack/PNG/Blue/Default/button_rectangle_gloss.png"
const BTN_PRESSED := "res://assets/kenney/ui-pack/PNG/Blue/Default/button_rectangle_depth_flat.png"
const PANEL := "res://assets/kenney/ui-pack/PNG/Blue/Default/button_rectangle_flat.png"

func style_button(btn: Button) -> void:
    for state in ["normal", "hover", "pressed", "disabled"]:
        var path := BTN
        if state == "hover": path = BTN_HOVER
        if state == "pressed": path = BTN_PRESSED
        if state == "disabled": path = BTN_PRESSED
        var tex := load(path)
        if tex == null: return
        var sb := StyleBoxTexture.new()
        sb.texture = tex
        sb.texture_margin_left = 8
        sb.texture_margin_top = 8
        sb.texture_margin_right = 8
        sb.texture_margin_bottom = 8
        btn.add_theme_stylebox_override(state, sb)
    btn.add_theme_color_override("font_color", Color.WHITE)
    btn.add_theme_font_size_override("font_size", 16)

func style_panel(panel: PanelContainer) -> void:
    var tex := load(PANEL)
    if tex == null: return
    var sb := StyleBoxTexture.new()
    sb.texture = tex
    sb.texture_margin_left = 12
    sb.texture_margin_top = 12
    sb.texture_margin_right = 12
    sb.texture_margin_bottom = 12
    panel.add_theme_stylebox_override("panel", sb)