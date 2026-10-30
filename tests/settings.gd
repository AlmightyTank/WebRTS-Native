extends Node
## Slice D: valid/invalid values, persistence, rollback and engine application.

var _failures: int = 0
const TEST_FILE: String = "user://test_settings_d.cfg"


func _ready() -> void:
    call_deferred("_run")


func _check(condition: bool, label: String) -> void:
    if not condition:
        _failures += 1
        printerr("FAIL: " + label)


func _clean() -> void:
    for suffix in ["", ".tmp", ".bak"]:
        var file: String = ProjectSettings.globalize_path(TEST_FILE + suffix)
        if FileAccess.file_exists(TEST_FILE + suffix):
            DirAccess.remove_absolute(file)


func _run() -> void:
    _clean()
    _check(SettingsService.set_storage_path_for_testing(TEST_FILE), "test storage isolation")
    _check(not SettingsService.reload(), "missing file returns safe defaults")
    var defaults: Dictionary = SettingsService.defaults()
    _check(SettingsService.snapshot() == defaults, "defaults restored")
    var unsafe: Dictionary = SettingsService.snapshot()
    unsafe["music_volume"] = 500
    _check(not SettingsService.update_many(unsafe), "entire invalid update rejected")
    _check(SettingsService.snapshot() == defaults, "rejected update leaves all values alone")
    _check(not SettingsService.set_option("ui_scale", 99.0), "out of-range UI scale rejected")
    _check(not SettingsService.set_option("resolution", "1x1"), "unknown resolution rejected")
    _check(not SettingsService.set_option("display_mode", "superfullscreen"), "unknown display mode rejected")
    _check(not SettingsService.set_option("master_volume", -1), "negative volume rejected")
    _check(not SettingsService.set_option("music_volume", 1.5), "fractional volume rejected")
    _check(not SettingsService.set_option("unknown", "hello"), "unrecognized keys rejected")

    var changes: Dictionary = SettingsService.snapshot()
    changes["display_mode"] = "fullscreen"
    changes["resolution"] = "1920x1080"
    changes["quality"] = "high"
    changes["ui_scale"] = 1.3
    changes["master_volume"] = 0
    changes["music_volume"] = 50
    changes["sfx_volume"] = 35
    changes["ui_volume"] = 70
    _check(SettingsService.update_many(changes), "valid setting group applies")
    _check(is_equal_approx(get_tree().root.content_scale_factor, 1.3), "native UI scale applied")
    _check(get_tree().root.msaa_3d == Viewport.MSAA_4X, "high preset configures renderer")
    _check(AudioServer.get_bus_index("Music") >= 0, "Music bus created")
    _check(AudioServer.get_bus_index("SFX") >= 0, "SFX bus created")
    _check(AudioServer.get_bus_index("UI") >= 0, "UI bus created")
    _check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")), "zero master volume mutes")
    _check(SettingsService.save(), "settings saved to user://")
    _check(FileAccess.file_exists(TEST_FILE), "settings file exists")
    SettingsService.reset_defaults()
    _check(SettingsService.get_setting("resolution") == "1280x720", "reset changes memory")
    _check(SettingsService.reload(), "reload saved file")
    _check(SettingsService.snapshot() == changes, "full snapshot survives restart")
    _check(SettingsService.save(), "second save can replace prior file")
    _check(FileAccess.file_exists(TEST_FILE + ".bak"), "previous save backed up")

    var tampered := ConfigFile.new()
    _check(tampered.load(TEST_FILE) == OK, "config readable")
    tampered.set_value("preferences", "master_volume", 999)
    tampered.set_value("preferences", "ui_scale", -9.0)
    tampered.set_value("preferences", "music_volume", "loud")
    _check(tampered.save(TEST_FILE) == OK, "simulate corrupt preferences")
    _check(SettingsService.reload(), "corrupt fields don't crash valid version load")
    _check(SettingsService.get_setting("master_volume") == defaults["master_volume"], "invalid master uses default")
    _check(SettingsService.get_setting("ui_scale") == defaults["ui_scale"], "invalid scale uses default")
    _check(SettingsService.get_setting("music_volume") == defaults["music_volume"], "invalid music uses default")
    _check(SettingsService.get_setting("quality") == "high", "good fields survive partial corruption")

    # An invalid primary file should recover from the previous valid save.
    tampered.set_value("meta", "schema_version", 999)
    _check(tampered.save(TEST_FILE) == OK, "simulate unsupported primary schema")
    _check(SettingsService.reload(), "recover unsupported primary version from backup")
    _check(SettingsService.snapshot() == changes, "version mismatch recovers prior settings")

    var file := FileAccess.open(TEST_FILE, FileAccess.WRITE)
    _check(file != null, "corrupt primary file opened")
    if file != null:
        file.store_string("definitely not valid config")
        file.close()
    _check(SettingsService.reload(), "recover unreadable primary from backup")
    _check(SettingsService.snapshot() == changes, "unreadable primary restores prior valid snapshot")

    # No usable primary or backup must fail safely to defaults.
    var backup_file := FileAccess.open(TEST_FILE + ".bak", FileAccess.WRITE)
    _check(backup_file != null, "corrupt backup file opened")
    if backup_file != null:
        backup_file.store_string("definitely not valid config")
        backup_file.close()
    _check(not SettingsService.reload(), "both corrupt files return safe defaults")
    _check(SettingsService.snapshot() == defaults, "both corrupt files use safe defaults")

    SettingsService.restore_production_storage_path()
    SettingsService.reset_defaults()
    _clean()
    if _failures == 0:
        print("PASS: native settings versioned save reload validation")
        get_tree().quit(0)
    else:
        printerr("FAIL: native settings had %d errors" % _failures)
        get_tree().quit(1)
