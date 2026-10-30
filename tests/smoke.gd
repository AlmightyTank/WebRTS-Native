extends SceneTree
## Run with: godot --headless --path . --script res://tests/smoke.gd

func _initialize() -> void:
    call_deferred("_run_smoke")


func _run_smoke() -> void:
    var startup_path: String = ProjectSettings.get_setting("application/run/main_scene", "")
    if startup_path != "res://scenes/MainMenu.tscn":
        printerr("FAIL: unexpected main scene: " + startup_path)
        quit(1)
        return

    var scene := load(startup_path) as PackedScene
    if scene == null:
        printerr("FAIL: main menu scene missing or unparsable")
        quit(1)
        return

    var root := scene.instantiate()
    if not (root is Control):
        printerr("FAIL: native main scene is not a Control")
        quit(1)
        return

    get_root().add_child(root)
    var skirmish := root.find_child("SkirmishButton", true, false) as Button
    var campaign := root.find_child("CampaignButton", true, false) as Button
    var status := root.find_child("StatusButton", true, false) as Button
    var exit_button := root.find_child("ExitButton", true, false) as Button

    if skirmish == null or campaign == null or status == null or exit_button == null:
        printerr("FAIL: main menu controls missing")
        quit(1)
        return
    if not skirmish.disabled or not campaign.disabled:
        printerr("FAIL: unfinished game modes must remain disabled")
        quit(1)
        return
    if status.disabled or exit_button.disabled:
        printerr("FAIL: active menu controls must be usable")
        quit(1)
        return
    status.pressed.emit()
    var label := root.find_child("StatusLabel", true, false) as Label
    if label == null or not label.text.contains("Slice A"):
        printerr("FAIL: native status button did not update its text")
        quit(1)
        return

    print("PASS: native Godot main menu boot and interaction smoke")
    quit(0)
