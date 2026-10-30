extends Node
## Test the actual Options scene's UI selection and Apply/Back boundaries.

var _failures: int = 0
const TEST_FILE: String = "user://test_options_ui.cfg"


func _ready() -> void:
    call_deferred("_run")


func _check(value: bool, label: String) -> void:
    if not value:
        _failures += 1
        printerr("FAIL: " + label)


func _get_control(name: String) -> Control:
    var screen: Control = SceneRouter.current_screen()
    if screen == null:
        return null
    return screen.find_child(name, true, false) as Control


func _run() -> void:
    _check(SettingsService.set_storage_path_for_testing(TEST_FILE), "use isolated options test path")
    SettingsService.reset_defaults()

    var app := (load("res://scenes/AppRoot.tscn") as PackedScene).instantiate()
    get_tree().root.add_child(app)
    _check(SceneRouter.navigate(&"options"), "navigate to Options")
    var display := _get_control("display_mode_select") as OptionButton
    var resolution := _get_control("resolution_select") as OptionButton
    var quality := _get_control("quality_select") as OptionButton
    var scale := _get_control("ui_scale_select") as OptionButton
    var music := _get_control("music_volume_slider") as HSlider
    var apply_btn := _get_control("ApplyButton") as Button
    var reset_btn := _get_control("ResetButton") as Button
    var back_btn := _get_control("BackButton") as Button
    _check(display != null and resolution != null and quality != null and scale != null,
        "all display controls present")
    _check(music != null and apply_btn != null and reset_btn != null and back_btn != null,
        "audio and action buttons present")
    if apply_btn == null or quality == null or scale == null or music == null:
        get_tree().quit(1)
        return

    quality.select(2)
    quality.item_selected.emit(2)
    scale.select(3)
    scale.item_selected.emit(3)
    music.value = 37
    _check(SettingsService.get_setting("quality") == "medium", "unsaved draft does not apply")
    apply_btn.pressed.emit()
    _check(SettingsService.get_setting("quality") == "high", "Apply persists quality")
    _check(is_equal_approx(float(SettingsService.get_setting("ui_scale")), 1.3), "Apply persists UI scale")
    _check(SettingsService.get_setting("music_volume") == 37, "Apply persists volume")
    _check(FileAccess.file_exists(TEST_FILE), "Apply wrote local settings")
    back_btn.pressed.emit()
    _check(SceneRouter.current_route() == &"menu", "Back returns to menu")
    _check(SceneRouter.navigate(&"options"), "reopen Options")
    var new_quality := _get_control("quality_select") as OptionButton
    _check(new_quality != null and new_quality.selected == 2, "stored quality selected when reopened")

    reset_btn = _get_control("ResetButton") as Button
    reset_btn.pressed.emit()
    _check(SettingsService.get_setting("quality") == "high", "Reset defaults is a draft only")
    (_get_control("BackButton") as Button).pressed.emit()
    _check(SceneRouter.navigate(&"options"), "reopen after discarded reset")
    _check((_get_control("quality_select") as OptionButton).selected == 2, "discard reset restores persisted values")
    (_get_control("ResetButton") as Button).pressed.emit()
    (_get_control("ApplyButton") as Button).pressed.emit()
    _check(SettingsService.snapshot() == SettingsService.defaults(), "Apply reset saved defaults")

    SettingsService.restore_production_storage_path()
    SettingsService.reset_defaults()
    for suffix in ["", ".tmp", ".bak"]:
        if FileAccess.file_exists(TEST_FILE + suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_FILE + suffix))
    if _failures == 0:
        print("PASS: native options UI apply discard defaults")
        get_tree().quit(0)
    else:
        printerr("FAIL: Options UI had %d errors" % _failures)
        get_tree().quit(1)
