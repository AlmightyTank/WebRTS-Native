extends Control
## Native offline preferences. Apply persists an atomic validated snapshot.
## Back discards unsaved changes; defaults are a staged draft until Apply.

const BACKDROP_SCRIPT = preload("res://scripts/menu_backdrop.gd")
const GOLD: Color = Color("#e8b56d")
const WHITE: Color = Color("#edf3f8")
const MUTED: Color = Color("#a2b3c0")

var _draft: Dictionary
var _controls: Dictionary = {}
var _notice: Label
var _applying: bool = false


func _ready() -> void:
    _draft = SettingsService.snapshot()
    _build()
    get_viewport().size_changed.connect(_adapt)
    _adapt()
    var mode: OptionButton = _controls["display_mode"]
    mode.grab_focus()


func _build() -> void:
    var backdrop: Control = BACKDROP_SCRIPT.new()
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(backdrop)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var margin := MarginContainer.new()
    margin.name = "SafeMargin"
    add_child(margin)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 12)

    var layout := VBoxContainer.new()
    layout.name = "OptionsLayout"
    layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(layout)

    var scroll := ScrollContainer.new()
    scroll.name = "OptionsScroller"
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    layout.add_child(scroll)

    var panel := PanelContainer.new()
    panel.name = "OptionsPanel"
    panel.custom_minimum_size.x = 340.0
    panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    scroll.add_child(panel)

    var inset := MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        inset.add_theme_constant_override("margin_" + side, 18)
    panel.add_child(inset)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 13)
    inset.add_child(box)
    box.add_child(_label("SYSTEM / PREFERENCES", 12, GOLD))
    box.add_child(_label("OPTIONS", 32, WHITE))
    box.add_child(_label("Stored locally on this device. No online account needed.", 14, MUTED))

    _add_choice(box, "display_mode", "DISPLAY MODE",
        ["Windowed", "Fullscreen"], ["windowed", "fullscreen"])
    _add_choice(box, "resolution", "WINDOW RESOLUTION",
        ["1280 × 720", "1600 × 900", "1920 × 1080"],
        ["1280x720", "1600x900", "1920x1080"])
    _add_choice(box, "quality", "GRAPHICS QUALITY",
        ["Low", "Medium", "High"], ["low", "medium", "high"])
    _add_choice(box, "ui_scale", "INTERFACE SCALE",
        ["85%", "100%", "115%", "130%", "150%"],
        [0.85, 1.0, 1.15, 1.3, 1.5])

    box.add_child(_label("AUDIO", 16, GOLD))
    for key in ["master_volume", "music_volume", "sfx_volume", "ui_volume"]:
        var heading: String = {
            "master_volume": "MASTER",
            "music_volume": "MUSIC",
            "sfx_volume": "SOUND EFFECTS",
            "ui_volume": "INTERFACE",
        }[key]
        _add_volume(box, key, heading)

    if OS.has_feature("mobile"):
        var mode: OptionButton = _controls["display_mode"]
        var resolution: OptionButton = _controls["resolution"]
        mode.disabled = true
        resolution.disabled = true
        box.add_child(_label("Display mode and resolution follow your mobile device.", 13, MUTED))

    # Keep the actions visible even when the form needs vertical scrolling.
    var footer := VBoxContainer.new()
    footer.name = "OptionsFooter"
    footer.add_theme_constant_override("separation", 6)
    layout.add_child(footer)

    _notice = _label("Changes are not saved until Apply.", 13, MUTED)
    _notice.name = "NoticeLabel"
    footer.add_child(_notice)

    var actions := HFlowContainer.new()
    actions.name = "OptionsActions"
    actions.add_theme_constant_override("h_separation", 8)
    actions.add_theme_constant_override("v_separation", 6)
    footer.add_child(actions)

    var apply_button := Button.new()
    apply_button.name = "ApplyButton"
    apply_button.text = "APPLY & SAVE"
    apply_button.custom_minimum_size = Vector2(145, 50)
    apply_button.pressed.connect(_apply_changes)
    actions.add_child(apply_button)

    var reset_button := Button.new()
    reset_button.name = "ResetButton"
    reset_button.text = "RESTORE DEFAULTS"
    reset_button.custom_minimum_size = Vector2(145, 50)
    reset_button.pressed.connect(_reset_draft)
    actions.add_child(reset_button)

    var back_button := Button.new()
    back_button.name = "BackButton"
    back_button.text = "BACK  •  DISCARD UNSAVED"
    back_button.custom_minimum_size = Vector2(175, 50)
    back_button.pressed.connect(_back)
    actions.add_child(back_button)


func _add_choice(box: VBoxContainer, key: String, title: String,
        labels: Array, values: Array) -> void:
    box.add_child(_label(title, 14, WHITE))
    var field := OptionButton.new()
    field.name = key + "_select"
    field.custom_minimum_size = Vector2(0, 49)
    for index in range(values.size()):
        field.add_item(String(labels[index]), index)
    field.selected = values.find(_draft[key])
    field.item_selected.connect(_choice_changed.bind(key, values))
    _controls[key] = field
    box.add_child(field)


func _add_volume(box: VBoxContainer, key: String, title: String) -> void:
    box.add_child(_label(title, 14, WHITE))
    var slider := HSlider.new()
    slider.name = key + "_slider"
    slider.custom_minimum_size = Vector2(0, 40)
    slider.min_value = 0
    slider.max_value = 100
    slider.step = 1
    slider.value = int(_draft[key])
    slider.value_changed.connect(_volume_changed.bind(key))
    _controls[key] = slider
    box.add_child(slider)


func _choice_changed(index: int, key: String, values: Array) -> void:
    if _applying or index < 0 or index >= values.size():
        return
    _draft[key] = values[index]
    _notice.text = "Unsaved changes."


func _volume_changed(value: float, key: String) -> void:
    if _applying:
        return
    _draft[key] = int(round(value))
    _notice.text = "Unsaved changes."


func _reset_draft() -> void:
    _draft = SettingsService.defaults()
    _sync_controls()
    _notice.text = "Defaults selected. Apply to save."


func _sync_controls() -> void:
    _applying = true
    var values: Dictionary = {
        "display_mode": ["windowed", "fullscreen"],
        "resolution": ["1280x720", "1600x900", "1920x1080"],
        "quality": ["low", "medium", "high"],
        "ui_scale": [0.85, 1.0, 1.15, 1.3, 1.5],
    }
    for key in values.keys():
        var select: OptionButton = _controls[key]
        select.select(values[key].find(_draft[key]))
    for key in ["master_volume", "music_volume", "sfx_volume", "ui_volume"]:
        var slider: HSlider = _controls[key]
        slider.value = _draft[key]
    _applying = false


func _apply_changes() -> void:
    var before: Dictionary = SettingsService.snapshot()
    if not SettingsService.update_many(_draft):
        _notice.text = "Invalid preferences; nothing saved."
        return
    if not SettingsService.save():
        SettingsService.update_many(before)
        _notice.text = "Could not write preferences; previous settings restored."
        return
    _notice.text = "Saved locally. Settings applied."


func _adapt() -> void:
    var panel := find_child("OptionsPanel", true, false) as PanelContainer
    var margin := find_child("SafeMargin", true, false) as MarginContainer
    if panel == null or margin == null:
        return
    var width_limit: float = maxf(300.0, float(get_viewport_rect().size.x) - 24.0)
    panel.custom_minimum_size.x = minf(490.0, width_limit)


func _label(value: String, px: int, tint: Color) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", px)
    label.add_theme_color_override("font_color", tint)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    return label


func _back() -> void:
    EventBus.back_requested.emit()
