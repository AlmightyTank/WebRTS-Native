# v0.1 Slice D — Settings persistence

## Scope
Make Options a functioning offline native preferences page, not a static mock.

## Implementation
- [x] Versioned ConfigFile (`user://settings.cfg`) with schema validation and safe defaults.
- [x] Staged write and previous-file backup; unknown/corrupt versions never crash startup.
- [x] Display mode (windowed/fullscreen) and three supported window resolutions on desktop.
- [x] Real 3D viewport MSAA quality presets (off/2x/4x).
- [x] Root viewport UI scale (85/100/115/130/150%).
- [x] Runtime Master/Music/SFX/UI audio buses with individual 0–100 volume and mute at zero.
- [x] Apply & Save, Restore Defaults as draft, Back discards unsaved preferences.
- [x] Android locks desktop-only display/resolution controls and uses device window configuration.
- [x] CI tests planned for defaults, malformed data, version mismatch, persistence, backup, menu integration.
- [ ] Windows and Linux CI verified green for current branch.
- [ ] Manual visible Windows inspection and Android device verification complete.
- [ ] Slice D merged into main.

## Manual test
1. Open Options from the main menu on Windows.
2. Set window resolution, fullscreen/windowed, quality, interface scale and each audio slider; click Apply & Save.
3. Close the game, reopen, confirm controls and actual renderer/window/audio preferences restored.
4. Make changes then Back without Apply, reopen Options and confirm unsaved changes discarded.
5. Restore Defaults and Apply, verify defaults are persisted.
6. If testing on Android, confirm desktop-only settings disabled, orientation/touch still usable and local storage persists.
7. No network account, browser or server required.

## Limitations
Current game has no 3D combat scene and no composed music/SFX playback yet. Quality and volume bus settings are applied at the engine level, but their visual/audio effects cannot be fully judged until content exists. Android export and physical-device validation are later slices.
