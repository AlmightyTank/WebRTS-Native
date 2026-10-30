extends Control
## Single persistent game-window root. Future systems (audio, HUD, overlays)
## can live beside ScreenHost instead of being recreated on navigation.

func _ready() -> void:
    var screen_host := Control.new()
    screen_host.name = "ScreenHost"
    add_child(screen_host)
    screen_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    if not SceneRouter.attach(screen_host):
        push_error("AppRoot: failed to attach SceneRouter")
