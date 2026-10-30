# Slice B — Scene and service architecture

## Hierarchy
```
AppRoot (Control, never replaced during normal navigation)
└── ScreenHost (Control, full rect)
    └── MainMenu | StatusScreen | later Campaign/Skirmish/etc. (one at a time)
```

## Autoloads (startup order)
1. **EventBus** — typed navigation, back, route-changed, session-changed and notification signals. UI publishes requests, not direct references to distant scenes.
2. **GameState** — in-memory session `phase`/`mode`. It never owns a scene, camera, renderer, or network resource; snapshots are detached copies. Modes other than `campaign`/`skirmish` are rejected; menu→loading→playing→paused/results→menu lifecycle validated.
3. **SceneRouter** — allowed route ID registry; persistent `ScreenHost`, unique active screen, bounded history via user actions, go-back and reset. It instantiates before replacing the current screen, rejects unknown destinations, and clears references on host disposal.

**Boot:** `project.godot` enters `scenes/AppRoot.tscn` and AppRoot attaches ScreenHost to SceneRouter, which loads `MainMenu.tscn`.

**Navigation:** MainMenu Status button emits `EventBus.navigation_requested.emit(&"status")`; router owns transition; StatusScreen back emits `EventBus.back_requested.emit()`. Back at root is no-op. Stack is not editable from caller code. Campaign/Skirmish buttons remain disabled.

**State rule:** navigation and game session state are independent. Navigating to StatusScreen must not start/stop a match. Future gameplay screens must explicitly request state changes from GameState. Invalid state transitions never emit a changed signal.

## Conventions
- Folder `core/`: autoload cross-screen services; no scene-specific presentation, persistence, or external HTTP.
- `scenes/`: Godot `.tscn` scenes; UI root must be `Control` for ScreenHost.
- `scripts/`: scripts for concrete UI scenes and presentation.
- `assets/`: bundled local assets under models, textures, ui, audio. No remote assets at runtime.
- `tests/`: fast headless regressions. New route must have a registered ID, a scene, navigation/back tests, and a cleanup test.
- Use `StringName` route IDs, never arbitrary file paths from UI signals. Centralize allowed routes in SceneRouter.
- No service should call `get_tree().change_scene_to_file()` for normal menu travel, because it would tear down AppRoot.
- Leave gameplay simulation separate from rendering. Maintain desktop/Android parity at command level in future slices.

## Testing
```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/smoke.gd
godot --headless --path . --script res://tests/architecture.gd
godot --headless --path . --quit-after 10
```
Linux and Windows GitHub CI both run the navigation/state tests. Human-visible UI on Windows and Android is still separate acceptance work.
