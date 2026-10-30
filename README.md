# Poly Warfront

An original **standalone, offline-first real-time strategy game** for Windows and Android, built with **Godot 4.7.2** and GDScript. Its target is an angled low-poly 3D battlefield, native menus and an integrated RTS HUD.

> **Current feature:** v0.1 Slice F Godot CI and native validation. The main menu is functional, but Campaign and Skirmish are intentionally disabled until gameplay exists. No combat or mission content is claimed complete.

This is the NEW native game. The original [Phaser WebRTS prototype](https://github.com/AlmightyTank/WebRTS) is a separate, unchanged reference.

## Get started

1. Install [Godot 4.7.2 standard edition](https://godotengine.org/download/archive/4.7.2-stable/).
2. Clone this repository; open the root `project.godot` in Godot.
3. Press **F5** to launch the standalone game window, with no browser or server. The native menu has Play (offline mode selector), Campaign, Skirmish, Load, Options, Credits, Development Status, and Quit. Options now saves display mode, resolution, graphics quality, interface scale and four volume groups locally in `user://settings.cfg`. Campaign, Skirmish and Load Game remain locked.

To run local foundation smoke checks from a command shell with `godot` installed:

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . res://tests/smoke.tscn
godot --headless --path . res://tests/architecture.tscn
godot --headless --path . res://tests/menu_input.tscn
godot --headless --path . res://tests/settings.tscn
godot --headless --path . res://tests/options_ui.tscn
godot --headless --path . res://tests/command_contract.tscn
godot --headless --path . res://tests/asset_validation.tscn
godot --headless --path . res://tests/battlefield_picking.tscn
godot --headless --path . res://tests/battlefield_camera_controls.tscn
godot --headless --path . res://tests/battlefield_touch_camera.tscn
godot --headless --path . --quit-after 10
```

The Windows CI job also exports and launches a versioned portable artifact:
`Poly-Warfront-v0.1.0-windows-x86_64-portable.zip`.

The Android CI job exports `Poly-Warfront-v0.1.0-debug.apk` and runs the
headless touch smoke scene. The v0.2 Slice A battlefield now also provides a fixed-angle 3D test scene and deterministic terrain picking. A physical Android device is still required for
hardware, safe-area, suspend/resume and APK installation acceptance.

See [scene architecture](docs/SCENE-ARCHITECTURE.md), [Slice B checklist](docs/SLICE-0.1-B.md), [development setup](docs/DEVELOPMENT.md), the [132-slice native roadmap](docs/ROADMAP-NATIVE-OFFLINE-1.0.md) and [Slice A acceptance](docs/SLICE-0.1-A.md).

## Release focus

- Windows and Android **offline** single-player first; local saves and AI, no logins, VPS or always-online requirement.
- Two original factions, complete skirmish, 20 authored campaign missions and 12 maps at 1.0.
- Multiplayer is optional after 1.0.
- Every new slice gets automated checks and a real-device acceptance gate. Never mark a planned game mechanic as complete based only on a menu mock.
