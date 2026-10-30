extends Node
## Native GUI inputs via Viewport.push_input rather than directly firing button signals.
## Linux/Windows headless checks simulate mouse, keyboard, and touch.

var _failures: int = 0


func _ready() -> void:
    call_deferred("_run")


func _check(ok: bool, message: String) -> void:
    if not ok:
        _failures += 1
        printerr("FAIL: " + message)


func _button(name: String) -> Button:
    var screen: Control = SceneRouter.current_screen()
    if screen == null:
        return null
    return screen.find_child(name, true, false) as Button


func _click_mouse(target: Button) -> void:
    if target == null:
        _check(false, "mouse target exists")
        return
    var pos: Vector2 = target.get_global_rect().get_center()
    for down in [true, false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.position = pos
        event.global_position = pos
        event.pressed = down
        get_viewport().push_input(event, true)


func _tap_touch(target: Button) -> void:
    if target == null:
        _check(false, "touch target exists")
        return
    var pos: Vector2 = target.get_global_rect().get_center()
    for down in [true, false]:
        var event := InputEventScreenTouch.new()
        event.index = 0
        event.position = pos
        event.pressed = down
        Input.parse_input_event(event)


func _key(code: Key) -> void:
    for down in [true, false]:
        var event := InputEventKey.new()
        event.keycode = code
        event.pressed = down
        get_viewport().push_input(event, true)


func _run() -> void:
    var packed := load("res://scenes/AppRoot.tscn") as PackedScene
    _check(packed != null, "AppRoot scene loads")
    if packed == null:
        get_tree().quit(1)
        return
    var root: Control = packed.instantiate() as Control
    get_tree().root.add_child(root)
    await get_tree().process_frame
    await get_tree().process_frame

    _check(SceneRouter.current_route() == &"menu", "boot starts in menu")
    for name in ["PlayButton", "OptionsButton", "CreditsButton", "StatusButton", "ExitButton"]:
        var item := _button(name)
        _check(item != null and not item.disabled, "active main button " + name)
        if item != null:
            _check(item.custom_minimum_size.y >= 48, "tap target height for " + name)
    for name in ["CampaignButton", "SkirmishButton", "LoadButton"]:
        var locked := _button(name)
        _check(locked != null and locked.disabled, "locked mode " + name)
        if locked != null:
            _check(locked.focus_mode == Control.FOCUS_NONE, "locked modes are skipped in keyboard focus")

    var play := _button("PlayButton")
    _check(get_viewport().gui_get_focus_owner() == play, "keyboard starts focused on Play")
    _key(KEY_ENTER)
    await get_tree().process_frame
    _check(SceneRouter.current_route() == &"play", "keyboard Enter activates Play")
    var campaign := _button("CampaignModeButton")
    var skirmish := _button("SkirmishModeButton")
    _check(campaign != null and campaign.disabled, "Play screen campaign locked")
    _check(skirmish != null and skirmish.disabled, "Play screen skirmish locked")
    _key(KEY_ESCAPE)
    await get_tree().process_frame
    _check(SceneRouter.current_route() == &"menu", "keyboard Escape returns to main")

    var options := _button("OptionsButton")
    _click_mouse(options)
    await get_tree().process_frame
    _check(SceneRouter.current_route() == &"options", "mouse click opens Options")
    var back_options := _button("BackButton")
    if back_options != null:
        print("DEBUG: Options back rect=", back_options.get_global_rect(), " viewport=", get_viewport().get_visible_rect())
    _click_mouse(back_options)
    await get_tree().process_frame
    await get_tree().process_frame
    _check(SceneRouter.current_route() == &"menu", "mouse click Back returns from Options")

    var credits := _button("CreditsButton")
    _tap_touch(credits)
    await get_tree().process_frame
    await get_tree().process_frame
    _check(SceneRouter.current_route() == &"credits", "screen touch opens Credits")
    _tap_touch(_button("BackButton"))
    await get_tree().process_frame
    await get_tree().process_frame
    _check(SceneRouter.current_route() == &"menu", "screen touch returns from Credits")

    var status := _button("StatusButton")
    _click_mouse(status)
    await get_tree().process_frame
    _check(SceneRouter.current_route() == &"status", "status preserved by new menu")
    _key(KEY_ESCAPE)
    await get_tree().process_frame
    _check(SceneRouter.current_route() == &"menu", "Escape also returns from Status")
    _check(GameState.current_phase() == &"menu", "UI navigation never starts gameplay")
    _check(SceneRouter.get_history().size() == 1, "menu interactions leave clean history")

    if _failures == 0:
        print("PASS: native main menu keyboard mouse touch input")
        get_tree().quit(0)
    else:
        printerr("FAIL: native menu input had %d failures" % _failures)
        get_tree().quit(1)
