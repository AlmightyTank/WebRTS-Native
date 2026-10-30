extends Node
## Owns screen lifecycle and history. Only allow registered scene IDs.
## Keeps menus inside a persistent game root; no SceneTree.change_scene_to_file.

const SCENES: Dictionary = {
    &"menu": "res://scenes/MainMenu.tscn",
    &"status": "res://scenes/StatusScreen.tscn",
    &"play": "res://scenes/PlayScreen.tscn",
    &"options": "res://scenes/OptionsScreen.tscn",
    &"credits": "res://scenes/CreditsScreen.tscn",
}

var _host: Control
var _active_scene: Control
var _history: Array[StringName] = []


func _ready() -> void:
    EventBus.navigation_requested.connect(_on_navigation_requested)
    EventBus.back_requested.connect(_on_back_requested)


func attach(host: Control) -> bool:
    if host == null or not host.is_inside_tree():
        return false
    if is_instance_valid(_host):
        if _host == host:
            return true
        detach()
    _host = host
    _host.tree_exiting.connect(_on_host_exiting.bind(host))
    return navigate(&"menu", true)


func detach() -> void:
    if is_instance_valid(_active_scene):
        _active_scene.queue_free()
    _active_scene = null
    _host = null
    _history.clear()


func navigate(route: StringName, reset_history: bool = false) -> bool:
    if not SCENES.has(route) or not is_instance_valid(_host):
        return false
    if not reset_history and current_route() == route:
        return true

    var next_history: Array[StringName] = []
    if not reset_history:
        for item in _history:
            next_history.append(item)
    next_history.append(route)
    return _switch_screen(route, next_history)


func go_back() -> bool:
    if _history.size() <= 1 or not is_instance_valid(_host):
        return false
    var next_history: Array[StringName] = []
    for i in range(_history.size() - 1):
        next_history.append(_history[i])
    return _switch_screen(next_history[-1], next_history)


func current_route() -> StringName:
    if _history.is_empty():
        return &""
    return _history[-1]


func can_go_back() -> bool:
    return _history.size() > 1


func get_history() -> Array[StringName]:
    # Do not expose mutable internal history.
    var copy: Array[StringName] = []
    for item in _history:
        copy.append(item)
    return copy


func current_screen() -> Control:
    return _active_scene if is_instance_valid(_active_scene) else null


func _switch_screen(route: StringName, next_history: Array[StringName]) -> bool:
    var scene_path: String = SCENES.get(route, "")
    var packed: PackedScene = load(scene_path) as PackedScene
    if packed == null:
        push_error("SceneRouter: missing scene for route %s" % route)
        return false
    var new_screen: Control = packed.instantiate() as Control
    if new_screen == null:
        push_error("SceneRouter: route %s is not a Control scene" % route)
        return false

    var old_screen: Control = _active_scene
    # Update state before ready() runs in the newly attached screen.
    _history = next_history
    _active_scene = new_screen
    _host.add_child(new_screen)
    new_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    if is_instance_valid(old_screen):
        _host.remove_child(old_screen)
        old_screen.queue_free()

    EventBus.route_changed.emit(route, _history.size())
    return true


func _on_navigation_requested(route: StringName) -> void:
    navigate(route)


func _on_back_requested() -> void:
    go_back()


func _on_host_exiting(host: Control) -> void:
    if _host == host:
        # Host owns its scene children; don't retain references to disposed roots.
        _active_scene = null
        _host = null
        _history.clear()
