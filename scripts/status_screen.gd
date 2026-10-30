extends Control
## Real second screen used to prove navigation/back and shared-state lifecycle.

const BACKDROP_SCRIPT = preload("res://scripts/menu_backdrop.gd")
const GOLD: Color = Color("#e8b56d")
const WHITE: Color = Color("#edf3f8")
const MUTED: Color = Color("#a2b3c0")


func _ready() -> void:
    name = "StatusScreen"
    var backdrop: Control = BACKDROP_SCRIPT.new()
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(backdrop)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var center := CenterContainer.new()
    center.name = "Content"
    add_child(center)
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(360.0, 280.0)
    center.add_child(panel)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 16)
    panel.add_child(box)

    box.add_child(_label("DEVELOPMENT STATUS", 32, WHITE))
    box.add_child(_label("WebRTS Native  •  v0.1", 18, GOLD))
    box.add_child(_label("Slice B: game state, navigation and event bus.", 15, MUTED))
    box.add_child(_label("Current phase: " + String(GameState.current_phase()), 15, MUTED))
    box.add_child(_label("Campaign and Skirmish are still in development.", 14, MUTED))

    var back := Button.new()
    back.name = "BackButton"
    back.text = "BACK TO MAIN MENU"
    back.custom_minimum_size.y = 52.0
    back.pressed.connect(_on_back_pressed)
    box.add_child(back)
    back.grab_focus()


func _label(value: String, size_px: int, color: Color) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_color_override("font_color", color)
    label.add_theme_font_size_override("font_size", size_px)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    return label


func _on_back_pressed() -> void:
    EventBus.back_requested.emit()
