extends Control
## Slice 0.1-C: responsive, keyboard/mouse/touch-accessible native title screen.
## Gameplay destinations remain explicitly locked until implemented.

const BACKDROP_SCRIPT = preload("res://scripts/menu_backdrop.gd")
const GOLD: Color = Color("#e8b56d")
const WHITE: Color = Color("#edf3f8")
const MUTED: Color = Color("#a2b3c0")
const BUTTON_HEIGHT: float = 51.0

var _safe_margin: MarginContainer
var _scroller: ScrollContainer
var _main_panel: PanelContainer
var _status_label: Label


func _ready() -> void:
    _build_menu()
    resized.connect(_adapt_layout)
    _adapt_layout()
    # Explicit initial focus permits keyboard-only activation without a mouse.
    var first := find_child("PlayButton", true, false) as Button
    if first != null:
        first.grab_focus()


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

    _scroller = ScrollContainer.new()
    _scroller.name = "MenuScroller"
    _scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    _scroller.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    _scroller.size_flags_vertical = Control.SIZE_EXPAND_FILL
    columns.add_child(_scroller)

    _main_panel = PanelContainer.new()
    _main_panel.name = "MainPanel"
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color("#111d2b")
    panel_style.border_color = Color("#4b5d65")
    panel_style.set_border_width_all(1)
    panel_style.set_corner_radius_all(10)
    _main_panel.add_theme_stylebox_override("panel", panel_style)
    _scroller.add_child(_main_panel)

    var panel_padding := MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        panel_padding.add_theme_constant_override("margin_" + side, 20)
    _main_panel.add_child(panel_padding)

    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 8)
    panel_padding.add_child(content)
    content.add_child(_make_label("YOUNG PROGRAMING  /  RTS DIVISION", 12, GOLD))
    content.add_child(_make_label("POLY WARFRONT", 49, WHITE))
    content.add_child(_make_label("NATIVE  •  OFFLINE STRATEGY", 15, MUTED))

    var spacer := Control.new()
    spacer.custom_minimum_size.y = 13
    content.add_child(spacer)

    # PLAY opens a real mode-selection screen; game modes are still locked.
    _add_route_button(content, "PlayButton", "PLAY", &"play",
        "Choose a single-player mode. Campaign and Skirmish are not implemented yet.")
    _add_locked_button(content, "CampaignButton", "CAMPAIGN  •  COMING SOON",
        "Campaign missions are planned for later development slices.")
    _add_locked_button(content, "SkirmishButton", "SKIRMISH  •  COMING SOON",
        "Offline AI skirmishes are planned for later development slices.")
    _add_locked_button(content, "LoadButton", "LOAD GAME  •  COMING SOON",
        "Local saved games will become available once the gameplay and persistence systems exist.")
    _add_route_button(content, "OptionsButton", "OPTIONS", &"options",
        "Configure locally saved display, sound, graphics and UI preferences.")
    _add_route_button(content, "CreditsButton", "CREDITS", &"credits",
        "View the project's development and technology credits.")
    _add_route_button(content, "StatusButton", "DEVELOPMENT STATUS", &"status",
        "Read the current development status.")

    var exit_button := _make_button("QUIT GAME", true)
    exit_button.name = "ExitButton"
    exit_button.tooltip_text = "Close Poly Warfront."
    exit_button.pressed.connect(_exit_game)
    content.add_child(exit_button)

    _status_label = _make_label(
        "v0.1 • Native menus only. No playable battles yet.",
        13, MUTED
    )
    _status_label.name = "StatusLabel"
    content.add_child(_status_label)
    content.add_child(_make_label("WINDOWS / ANDROID  •  GODOT 4.7.2", 12, GOLD))

    var right_spacer := Control.new()
    right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    columns.add_child(right_spacer)


func _add_route_button(parent: VBoxContainer, node_name: String,
        title: String, route: StringName, hint: String) -> void:
    var button := _make_button(title, true)
    button.name = node_name
    button.tooltip_text = hint
    button.pressed.connect(_navigate.bind(route))
    parent.add_child(button)


func _add_locked_button(parent: VBoxContainer, node_name: String,
        title: String, hint: String) -> void:
    var button := _make_button(title, false)
    button.name = node_name
    button.tooltip_text = hint
    button.focus_mode = Control.FOCUS_NONE
    parent.add_child(button)


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
    button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
    button.custom_minimum_size = Vector2(0.0, BUTTON_HEIGHT)
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

    var focus := StyleBoxFlat.new()
    focus.bg_color = Color(0, 0, 0, 0)
    focus.border_color = GOLD
    focus.set_border_width_all(2)
    focus.set_corner_radius_all(5)
    button.add_theme_stylebox_override("focus", focus)
    return button


func _adapt_layout() -> void:
    if _safe_margin == null or _main_panel == null or _scroller == null:
        return
    var narrow: bool = size.x < 720.0
    var horizontal_margin: int = 12 if narrow else 52
    var vertical_margin: int = 8 if size.y < 600.0 else (14 if narrow else 24)
    _safe_margin.add_theme_constant_override("margin_left", horizontal_margin)
    _safe_margin.add_theme_constant_override("margin_right", horizontal_margin)
    _safe_margin.add_theme_constant_override("margin_top", vertical_margin)
    _safe_margin.add_theme_constant_override("margin_bottom", vertical_margin)
    var panel_width: float = minf(460.0, maxf(230.0, size.x - float(horizontal_margin * 2)))
    _scroller.custom_minimum_size.x = panel_width
    _main_panel.custom_minimum_size.x = panel_width


func _navigate(route: StringName) -> void:
    EventBus.navigation_requested.emit(route)


func _exit_game() -> void:
    get_tree().quit()
