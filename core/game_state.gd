extends Node
## Platform-agnostic in-memory session lifecycle, separate from scenes/rendering.
## No gameplay rules or persistence yet (these arrive in later slices).

const ALLOWED_TRANSITIONS: Dictionary = {
    &"menu": [&"loading"],
    &"loading": [&"playing", &"menu"],
    &"playing": [&"paused", &"results", &"menu"],
    &"paused": [&"playing", &"menu"],
    &"results": [&"menu"],
}

var _phase: StringName = &"menu"
var _mode: StringName = &"none"


func current_phase() -> StringName:
    return _phase


func current_mode() -> StringName:
    return _mode


func snapshot() -> Dictionary:
    # Caller owns its copy, so later screen code cannot mutate shared state.
    return {"phase": _phase, "mode": _mode}


func begin_session(mode: StringName) -> bool:
    if _phase != &"menu":
        return false
    if mode != &"campaign" and mode != &"skirmish":
        return false
    _mode = mode
    _phase = &"loading"
    _notify_changed()
    return true


func transition(next_phase: StringName) -> bool:
    if next_phase == _phase:
        return false
    var allowed: Array = ALLOWED_TRANSITIONS.get(_phase, [])
    if not allowed.has(next_phase):
        return false
    _phase = next_phase
    if _phase == &"menu":
        _mode = &"none"
    _notify_changed()
    return true


func reset_to_menu() -> void:
    if _phase == &"menu" and _mode == &"none":
        return
    _phase = &"menu"
    _mode = &"none"
    _notify_changed()


func _notify_changed() -> void:
    EventBus.session_changed.emit(snapshot())
