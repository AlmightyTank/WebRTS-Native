extends Control
## Single persistent game-window root. Future systems (audio, HUD, overlays)
## can live beside ScreenHost instead of being recreated on navigation.

func _unhandled_key_input(event: InputEvent) -> void:
    # Godot's built-in ui_cancel covers Escape and gamepad/mobile back mappings.
    if event.is_action_pressed("ui_cancel") and not event.is_echo():
        if SceneRouter.can_go_back():
            EventBus.back_requested.emit()
            get_viewport().set_input_as_handled()


func _ready() -> void:
    var screen_host := Control.new()
    screen_host.name = "ScreenHost"
    add_child(screen_host)
    screen_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    if not SceneRouter.attach(screen_host):
        push_error("AppRoot: failed to attach SceneRouter")
