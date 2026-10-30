extends Node
## Headless regression: route history, signals, state transitions and root disposal.

var _failures: int = 0
var _routes_seen: Array[StringName] = []
var _phases_seen: Array[StringName] = []


func _ready() -> void:
    call_deferred("_run_tests")


func _check(condition: bool, message: String) -> void:
    if not condition:
        _failures += 1
        printerr("FAIL: " + message)


func _run_tests() -> void:
    EventBus.route_changed.connect(_record_route)
    EventBus.session_changed.connect(_record_state)

    _check(GameState.current_phase() == &"menu", "default phase is menu")
    _check(GameState.current_mode() == &"none", "default mode is none")
    _check(not GameState.transition(&"playing"), "cannot play before a session begins")
    _check(not GameState.begin_session(&"invalid"), "reject unknown game mode")
    _check(GameState.begin_session(&"skirmish"), "session may begin in loading")
    _check(GameState.current_phase() == &"loading", "session starts loading")
    var snapshot: Dictionary = GameState.snapshot()
    snapshot["phase"] = &"tampered"
    _check(GameState.current_phase() == &"loading", "snapshot mutation cannot change service")
    _check(GameState.transition(&"playing"), "loading may enter playing")
    _check(GameState.transition(&"paused"), "playing may enter paused")
    _check(not GameState.transition(&"loading"), "paused may not return to loading")
    _check(GameState.transition(&"playing"), "paused may resume")
    _check(GameState.transition(&"results"), "playing may finish")
    _check(GameState.transition(&"menu"), "results may return to menu")
    _check(GameState.current_mode() == &"none", "return to menu clears mode")
    _check(_phases_seen.size() == 6, "emits exact session lifecycle events")

    var main_scene := load("res://scenes/AppRoot.tscn") as PackedScene
    _check(main_scene != null, "AppRoot is a valid packed scene")
    if main_scene == null:
        get_tree().quit(1)
        return
    var root := main_scene.instantiate()
    get_tree().root.add_child(root)

    _check(SceneRouter.current_route() == &"menu", "attach opens main menu")
    _check(SceneRouter.get_history().size() == 1, "initial stack has one route")
    _check(not SceneRouter.can_go_back(), "cannot back out of root")
    _check(not SceneRouter.go_back(), "back on root is harmless")
    _check(not SceneRouter.navigate(&"invalid"), "unregistered routes rejected")
    _check(SceneRouter.current_route() == &"menu", "invalid route is non-destructive")
    _check(SceneRouter.navigate(&"menu"), "same route is accepted as no-op")
    _check(SceneRouter.get_history().size() == 1, "same route never duplicates history")

    var original_menu: Control = SceneRouter.current_screen()
    EventBus.navigation_requested.emit(&"status")
    _check(SceneRouter.current_route() == &"status", "bus navigation opens status")
    _check(SceneRouter.get_history().size() == 2, "navigation appends history")
    _check(SceneRouter.can_go_back(), "status allows back")
    _check(_routes_seen.size() == 2, "startup and status emit route events")
    _check(_routes_seen[-1] == &"status", "route event carries destination")
    var host := root.get_node("ScreenHost") as Control
    _check(host.get_child_count() == 1, "only one active screen in host")
    _check(original_menu.get_parent() == null, "old screen unmounted")
    _check(SceneRouter.get_history() == [&"menu", &"status"], "correct stack order")
    var history_copy: Array[StringName] = SceneRouter.get_history()
    history_copy.clear()
    _check(SceneRouter.get_history().size() == 2, "caller cannot mutate history")

    EventBus.back_requested.emit()
    _check(SceneRouter.current_route() == &"menu", "back returns to main menu")
    _check(SceneRouter.get_history().size() == 1, "back pops history")
    _check(host.get_child_count() == 1, "back does not retain old screens")
    _check(SceneRouter.navigate(&"status"), "status opens again")
    _check(SceneRouter.navigate(&"menu", true), "reset history returns to root")
    _check(not SceneRouter.can_go_back(), "reset history clears back stack")
    _check(host.get_child_count() == 1, "reset keeps single screen")

    root.queue_free()
    # Process pending frees and exit notifications before checking detached state.
    await get_tree().process_frame
    await get_tree().process_frame
    _check(SceneRouter.current_route() == &"", "disposed AppRoot clears route history")
    _check(SceneRouter.current_screen() == null, "disposed AppRoot clears screen pointer")
    _check(not SceneRouter.navigate(&"status"), "cannot navigate without host")

    # Reattach fresh root (e.g., later title/restart flow).
    var next_root := main_scene.instantiate()
    get_tree().root.add_child(next_root)
    _check(SceneRouter.current_route() == &"menu", "fresh root can attach")
    _check(SceneRouter.get_history().size() == 1, "fresh root has clean history")

    if _failures == 0:
        print("PASS: architecture navigation state lifecycle")
        get_tree().quit(0)
    else:
        printerr("FAIL: architecture had %d failures" % _failures)
        get_tree().quit(1)


func _record_route(route: StringName, _depth: int) -> void:
    _routes_seen.append(route)


func _record_state(snapshot: Dictionary) -> void:
    _phases_seen.append(snapshot.get("phase", &""))
