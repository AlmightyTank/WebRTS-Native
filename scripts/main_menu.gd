extends Control
## Slice 0.1-A: actual Godot-native game-window menu, not a web wrapper.
## Incomplete gameplay destinations are visibly disabled until implemented.

const BACKDROP_SCRIPT = preload("res://scripts/menu_backdrop.gd")
const GOLD: Color = Color("#e8b56d")
const WHITE: Color = Color("#edf3f8")
const MUTED: Color = Color("#a2b3c0")

var _safe_margin: MarginContainer
var _main_panel: PanelContainer
var _status_label: Label


func _ready() -> void:
    _build_menu()
    resized.connect(_adapt_layout)
    _adapt_layout()


func _build_menu() -> void:
    var background: Control = BACKDROP_SCRIPT.new()
    background.name = "Backdrop"
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    _safe_margin = MarginContainer.new()
    _safe_margin.name = "SafeMargin"
    add_child(_safe_margin)
    _safe_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var columns := HBoxContainer.new()
    _safe_margin.add_child(columns)

    _main_panel = PanelContainer.new()
    _main_panel.name = "MainPanel"
    _main_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color("#111d2b")
    panel_style.border_color = Color("#4b5d65")
    panel_style.set_border_width_all(1)
    panel_style.set_corner_radius_all(10)
    _main_panel.add_theme_stylebox_override("panel", panel_style)
    columns.add_child(_main_panel)

    var panel_padding := MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        panel_padding.add_theme_constant_override("margin_" + side, 24)
    _main_panel.add_child(panel_padding)

    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 13)
    panel_padding.add_child(content)

    content.add_child(_make_label("YOUNG PROGRAMING  /  RTS DIVISION", 12, GOLD))
    content.add_child(_make_label("WEBRTS", 52, WHITE))
    content.add_child(_make_label("NATIVE  •  OFFLINE STRATEGY", 16, MUTED))

    var spacer := Control.new()
    spacer.custom_minimum_size.y = 16
    content.add_child(spacer)

    var skirmish := _make_button("SKIRMISH  •  IN DEVELOPMENT", false)
    skirmish.name = "SkirmishButton"
    content.add_child(skirmish)

    var campaign := _make_button("CAMPAIGN  •  IN DEVELOPMENT", false)
    campaign.name = "CampaignButton"
    content.add_child(campaign)

    var info := _make_button("DEVELOPMENT STATUS", true)
    info.name = "StatusButton"
    info.pressed.connect(_show_status)
    content.add_child(info)

    var quit_button := _make_button("EXIT GAME", true)
    quit_button.name = "ExitButton"
    quit_button.pressed.connect(_exit_game)
    content.add_child(quit_button)

    _status_label = _make_label(
        "v0.1 • Native foundation. Gameplay arrives in future slices.",
        13,
        MUTED
    )
    _status_label.name = "StatusLabel"
    content.add_child(_status_label)

    var footer := _make_label("WINDOWS / ANDROID  •  GODOT 4.7.2", 12, GOLD)
    content.add_child(footer)

    var right_spacer := Control.new()
    right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    columns.add_child(right_spacer)


func _make_label(value: String, font_size: int, tint: Color) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", tint)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    return label


func _make_button(value: String, enabled: bool) -> Button:
    var button := Button.new()
    button.text = value
    button.disabled = not enabled
    button.custom_minimum_size = Vector2(0.0, 48.0)
    button.add_theme_font_size_override("font_size", 15)
    button.add_theme_color_override("font_color", WHITE)
    button.add_theme_color_override("font_disabled_color", Color("#7b8892"))

    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("#183243")
    normal.border_color = Color("#335163")
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(5)
    normal.content_margin_left = 10.0
    normal.content_margin_right = 10.0
    button.add_theme_stylebox_override("normal", normal)

    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color("#265367")
    button.add_theme_stylebox_override("hover", hover)

    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color("#113046")
    button.add_theme_stylebox_override("pressed", pressed)

    var disabled := normal.duplicate() as StyleBoxFlat
    disabled.bg_color = Color("#15222b")
    button.add_theme_stylebox_override("disabled", disabled)
    return button


func _adapt_layout() -> void:
    if _safe_margin == null or _main_panel == null:
        return
    var narrow: bool = size.x < 720.0
    var horizontal_margin: int = 14 if narrow else 64
    var vertical_margin: int = 14 if narrow else 36
    _safe_margin.add_theme_constant_override("margin_left", horizontal_margin)
    _safe_margin.add_theme_constant_override("margin_right", horizontal_margin)
    _safe_margin.add_theme_constant_override("margin_top", vertical_margin)
    _safe_margin.add_theme_constant_override("margin_bottom", vertical_margin)
    _main_panel.custom_minimum_size = Vector2(
        minf(470.0, maxf(0.0, size.x - float(horizontal_margin * 2))),
        0.0
    )


func _show_status() -> void:
    _status_label.text = "Slice A: native boot/menu. Next: scene architecture, RTS camera and controls."


func _exit_game() -> void:
    get_tree().quit()
