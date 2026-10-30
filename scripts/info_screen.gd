extends Control
## Self-contained presentation for the playable menu routes.
## Campaign, Skirmish, and Load do NOT fake gameplay or persistence.

@export_enum("play", "options", "credits") var screen_id: String = "play"

const BACKDROP_SCRIPT = preload("res://scripts/menu_backdrop.gd")
const GOLD: Color = Color("#e8b56d")
const WHITE: Color = Color("#edf3f8")
const MUTED: Color = Color("#a2b3c0")


func _ready() -> void:
    var backdrop: Control = BACKDROP_SCRIPT.new()
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(backdrop)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var margin := MarginContainer.new()
    add_child(margin)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 12)


    var scroll := ScrollContainer.new()
    scroll.name = "ContentScroller"
    scroll.custom_minimum_size.x = 320.0
    scroll.custom_minimum_size.y = 0.0
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    margin.add_child(scroll)

    var panel := PanelContainer.new()
    panel.custom_minimum_size.x = 320.0
    panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    scroll.add_child(panel)

    var inset := MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        inset.add_theme_constant_override("margin_" + side, 18)
    panel.add_child(inset)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 15)
    inset.add_child(box)

    var heading: String = ""
    match screen_id:
        "play":
            heading = "CHOOSE GAME MODE"
            box.add_child(_label("PLAY / OFFLINE SINGLE-PLAYER", 12, GOLD))
            box.add_child(_label(heading, 29, WHITE))
            box.add_child(_label("The native game is being built one slice at a time.", 16, MUTED))
            _add_disabled(box, "CampaignModeButton", "CAMPAIGN  •  NOT YET PLAYABLE")
            _add_disabled(box, "SkirmishModeButton", "SKIRMISH  •  NOT YET PLAYABLE")
            box.add_child(_label("These options unlock only when missions and AI matches exist.", 14, MUTED))
        "options":
            heading = "OPTIONS"
            box.add_child(_label("SYSTEM / PREFERENCES", 12, GOLD))
            box.add_child(_label(heading, 29, WHITE))
            box.add_child(_label("Options screen ready. Persistent settings arrive in v0.1 Slice D.", 16, MUTED))
            box.add_child(_label("Planned: fullscreen, resolution, sound, graphics quality, and UI scale.", 14, MUTED))
            box.add_child(_label("No settings have been changed or saved.", 14, GOLD))
        "credits":
            heading = "CREDITS"
            box.add_child(_label("PROJECT / TEAM", 12, GOLD))
            box.add_child(_label(heading, 29, WHITE))
            box.add_child(_label("A Young Programing project", 19, GOLD))
            box.add_child(_label("Poly Warfront — original standalone strategy game.", 16, MUTED))
            box.add_child(_label("Built with the open-source Godot Engine.", 16, MUTED))
            box.add_child(_label("Full contributors, artists and licenses will be credited as assets are added.", 14, MUTED))
        _:
            push_error("Unknown info screen ID: %s" % screen_id)
            return

    var back := Button.new()
    back.name = "BackButton"
    back.text = "BACK TO MAIN MENU"
    back.custom_minimum_size.y = 54.0
    back.focus_mode = Control.FOCUS_ALL
    back.pressed.connect(_on_back)
    box.add_child(back)
    back.grab_focus()


func _add_disabled(box: VBoxContainer, node_name: String, title: String) -> void:
    var button := Button.new()
    button.name = node_name
    button.text = title
    button.disabled = true
    button.focus_mode = Control.FOCUS_NONE
    button.custom_minimum_size.y = 54.0
    box.add_child(button)


func _label(value: String, size_px: int, color: Color) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_color_override("font_color", color)
    label.add_theme_font_size_override("font_size", size_px)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    return label


func _on_back() -> void:
    EventBus.back_requested.emit()
