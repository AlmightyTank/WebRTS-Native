extends Node
## v0.1-D offline preferences. Pure schema validation before applying.
## A staged write + backup protects the previous valid file on write failure.

signal settings_changed(values: Dictionary)

const SCHEMA_VERSION: int = 1
const STORAGE_PATH: String = "user://settings.cfg"
const RESOLUTIONS: Array[String] = ["1280x720", "1600x900", "1920x1080"]
const QUALITY_PRESETS: Array[String] = ["low", "medium", "high"]
const UI_SCALES: Array[float] = [0.85, 1.0, 1.15, 1.3, 1.5]
const DEFAULTS: Dictionary = {
    "display_mode": "windowed",
    "resolution": "1280x720",
    "quality": "medium",
    "ui_scale": 1.0,
    "master_volume": 80,
    "music_volume": 65,
    "sfx_volume": 80,
    "ui_volume": 80,
}

var _storage_path: String = STORAGE_PATH
var _values: Dictionary = DEFAULTS.duplicate(true)


func _ready() -> void:
    reload()
    apply()


func snapshot() -> Dictionary:
    return _values.duplicate(true)


func get_setting(key: String) -> Variant:
    return _values.get(key, null)


func defaults() -> Dictionary:
    return DEFAULTS.duplicate(true)


func storage_path() -> String:
    return _storage_path


func set_storage_path_for_testing(path: String) -> bool:
    # A test-only hook; production settings always use user://settings.cfg.
    if not OS.has_feature("editor") and not OS.has_feature("debug"):
        return false
    if not path.begins_with("user://"):
        return false
    _storage_path = path
    return true


func restore_production_storage_path() -> void:
    _storage_path = STORAGE_PATH


func reset_defaults() -> void:
    _values = defaults()
    apply()
    settings_changed.emit(snapshot())


func set_option(key: String, value: Variant) -> bool:
    if not DEFAULTS.has(key) or not _valid(key, value):
        return false
    _values[key] = value
    apply()
    settings_changed.emit(snapshot())
    return true


func update_many(candidate: Dictionary) -> bool:
    # All-or-nothing update prevents partial UI saves.
    if candidate.size() != DEFAULTS.size():
        return false
    for key in DEFAULTS.keys():
        if not candidate.has(key) or not _valid(key, candidate[key]):
            return false
    _values = candidate.duplicate(true)
    apply()
    settings_changed.emit(snapshot())
    return true


func reload() -> bool:
    _values = defaults()
    var config := ConfigFile.new()
    if config.load(_storage_path) != OK:
        settings_changed.emit(snapshot())
        return false
    if config.get_value("meta", "schema_version", -1) != SCHEMA_VERSION:
        settings_changed.emit(snapshot())
        return false
    for key in DEFAULTS.keys():
        var value: Variant = config.get_value("preferences", key, DEFAULTS[key])
        if _valid(key, value):
            _values[key] = value
    settings_changed.emit(snapshot())
    return true


func save() -> bool:
    var config := ConfigFile.new()
    config.set_value("meta", "schema_version", SCHEMA_VERSION)
    for key in DEFAULTS.keys():
        config.set_value("preferences", key, _values[key])

    var staged: String = _storage_path + ".tmp"
    if config.save(staged) != OK:
        return false
    var dest: String = ProjectSettings.globalize_path(_storage_path)
    var source: String = ProjectSettings.globalize_path(staged)
    var previous: String = dest + ".bak"
    if FileAccess.file_exists(_storage_path):
        if DirAccess.copy_absolute(dest, previous) != OK:
            DirAccess.remove_absolute(source)
            return false
    if DirAccess.rename_absolute(source, dest) != OK:
        # Some filesystems cannot atomically replace a destination.
        # Safely restore the previous file if the replacement fails.
        if FileAccess.file_exists(_storage_path):
            DirAccess.remove_absolute(dest)
        if DirAccess.rename_absolute(source, dest) != OK:
            if FileAccess.file_exists(previous):
                DirAccess.copy_absolute(previous, dest)
            DirAccess.remove_absolute(source)
            return false
    return true


func apply() -> void:
    # Headless CI has no real display. Still apply render/audio preferences.
    var root: Window = get_tree().root
    root.content_scale_factor = float(_values["ui_scale"])
    match String(_values["quality"]):
        "low":
            root.msaa_3d = Viewport.MSAA_DISABLED
        "medium":
            root.msaa_3d = Viewport.MSAA_2X
        "high":
            root.msaa_3d = Viewport.MSAA_4X

    _ensure_audio_buses()
    for key in ["master_volume", "music_volume", "sfx_volume", "ui_volume"]:
        var bus_name: String = {
            "master_volume": "Master",
            "music_volume": "Music",
            "sfx_volume": "SFX",
            "ui_volume": "UI",
        }[key]
        var index: int = AudioServer.get_bus_index(bus_name)
        if index >= 0:
            var linear: float = float(_values[key]) / 100.0
            AudioServer.set_bus_mute(index, linear <= 0.0)
            AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))

    if DisplayServer.get_name() != "headless" and not OS.has_feature("mobile"):
        var mode: int = DisplayServer.WINDOW_MODE_WINDOWED
        if _values["display_mode"] == "fullscreen":
            mode = DisplayServer.WINDOW_MODE_FULLSCREEN
        DisplayServer.window_set_mode(mode)
        if mode == DisplayServer.WINDOW_MODE_WINDOWED:
            var pieces: PackedStringArray = String(_values["resolution"]).split("x")
            DisplayServer.window_set_size(Vector2i(int(pieces[0]), int(pieces[1])))


func _ensure_audio_buses() -> void:
    for name in ["Music", "SFX", "UI"]:
        if AudioServer.get_bus_index(name) == -1:
            var new_index: int = AudioServer.bus_count
            AudioServer.add_bus(new_index)
            AudioServer.set_bus_name(new_index, name)
            AudioServer.set_bus_send(new_index, "Master")


func _valid(key: String, value: Variant) -> bool:
    match key:
        "display_mode":
            return typeof(value) == TYPE_STRING and value in ["windowed", "fullscreen"]
        "resolution":
            return typeof(value) == TYPE_STRING and value in RESOLUTIONS
        "quality":
            return typeof(value) == TYPE_STRING and value in QUALITY_PRESETS
        "ui_scale":
            if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
                return false
            for preset in UI_SCALES:
                if is_equal_approx(float(value), preset):
                    return true
            return false
        "master_volume", "music_volume", "sfx_volume", "ui_volume":
            return typeof(value) == TYPE_INT and value >= 0 and value <= 100
    return false
