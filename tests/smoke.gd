extends Node
## CI bootstrap smoke: the real main scene boots and navigates through an actual second screen.

func _ready() -> void:
    call_deferred("_run_smoke")


func _run_smoke() -> void:
    var startup_path: String = ProjectSettings.get_setting("application/run/main_scene", "")
    if startup_path != "res://scenes/AppRoot.tscn":
        printerr("FAIL: unexpected main scene: " + startup_path)
        get_tree().quit(1)
        return

    var scene := load(startup_path) as PackedScene
    if scene == null:
        printerr("FAIL: AppRoot scene missing")
        quit(1)
        return

    var root := scene.instantiate()
    get_tree().root.add_child(root)
    if SceneRouter.current_route() != &"menu":
        printerr("FAIL: app root did not open main menu")
        quit(1)
        return

    var menu := SceneRouter.current_screen()
    var skirmish := menu.find_child("SkirmishButton", true, false) as Button
    var campaign := menu.find_child("CampaignButton", true, false) as Button
    var status := menu.find_child("StatusButton", true, false) as Button
    var exit_button := menu.find_child("ExitButton", true, false) as Button
    if skirmish == null or campaign == null or status == null or exit_button == null:
        printerr("FAIL: main menu controls missing")
        quit(1)
        return
    if not skirmish.disabled or not campaign.disabled or status.disabled or exit_button.disabled:
        printerr("FAIL: main menu disabled/active state incorrect")
        quit(1)
        return

    status.pressed.emit()
    if SceneRouter.current_route() != &"status":
        printerr("FAIL: status button failed to navigate")
        quit(1)
        return
    var back := SceneRouter.current_screen().find_child("BackButton", true, false) as Button
    if back == null or back.disabled:
        printerr("FAIL: status back button missing")
        quit(1)
        return
    back.pressed.emit()
    if SceneRouter.current_route() != &"menu":
        printerr("FAIL: back button failed to return")
        quit(1)
        return

    print("PASS: native Godot main menu boot and interaction smoke")
    get_tree().quit(0)
