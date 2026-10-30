# v0.1 Slice C — Complete native main menu

## Scope
Finish the native main menu using the v0.1-B persistent AppRoot, SceneRouter, and EventBus.
All main menu destinations must be visible. Incomplete gameplay should never be presented as playable.

## Implementation
- [x] Play opens a mode-select screen with explicitly disabled Campaign/Skirmish choices.
- [x] Campaign, Skirmish and Load Game appear on main menu, visibly disabled with explanatory tooltips.
- [x] Options overview opens as a real screen; persistent settings are explicitly v0.1 Slice D.
- [x] Credits screen with project/engine attribution and back navigation.
- [x] Status screen remains accessible, Quit exits the native app.
- [x] Keyboard focus, Tab/Shift+Tab/Enter and Escape back navigation integrated with native controls.
- [x] Mouse/touch-friendly minimum 51px tall menu buttons and vertically scrollable narrow/short viewport layout.
- [x] Native menu smoke test expanded for destination and locked-state coverage.
- [x] Viewport-injected mouse, keyboard and screen touch input test suite added to Linux/Windows CI. Real-device taps still require physical acceptance.
- [ ] Linux and Windows latest CI run both passed.
- [ ] Real Windows and Android/touch hardware inspection completed.
- [ ] Slice C merged into main after final acceptance.

## Manual acceptance
1. Open `project.godot` with Godot 4.7.2 and press F5.
2. Confirm **PLAY, CAMPAIGN, SKIRMISH, LOAD GAME, OPTIONS, CREDITS, DEVELOPMENT STATUS, QUIT GAME** are visible (scroll on short displays).
3. Campaign, Skirmish and Load Game must be visibly disabled, not start empty matches or fake saves.
4. Play opens mode selection; its unfinished game types remain disabled; Back returns to the main menu.
5. Options explicitly says persistence is a later slice. Credits shows Young Programing and Godot. Both return.
6. Use mouse click, keyboard Tab/Shift+Tab and Enter; test Escape from the subpages.
7. On an Android device or emulator, tap and scroll the menu, open and exit active pages; verify safe areas.
8. Quit must close the game. The game must function without an HTTP server or online services.

## Follow-up
Slice D implements real preferences storage, resolution/windowing, volume buses, quality presets and UI scale.
