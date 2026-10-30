# WebRTS Native

An original **standalone, offline-first real-time strategy game** for Windows and Android, built with **Godot 4.7.2** and GDScript. Its target is an angled low-poly 3D battlefield, native menus and an integrated RTS HUD.

> **Current branch:** v0.1 Slice B architecture. The main menu is functional, but Campaign and Skirmish are intentionally disabled until gameplay exists. No combat or mission content is claimed complete.

This is the NEW native game. The original [Phaser WebRTS prototype](https://github.com/AlmightyTank/WebRTS) is a separate, unchanged reference.

## Get started

1. Install [Godot 4.7.2 standard edition](https://godotengine.org/download/archive/4.7.2-stable/).
2. Clone this repository; open the root `project.godot` in Godot.
3. Press **F5** to launch the standalone game window, with no browser or server. The Development Status button opens a separate native screen and Back returns to the main menu.

To run local foundation smoke checks from a command shell with `godot` installed:

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . res://tests/smoke.tscn
godot --headless --path . res://tests/architecture.tscn
godot --headless --path . --quit-after 10
```

See [scene architecture](docs/SCENE-ARCHITECTURE.md), [Slice B checklist](docs/SLICE-0.1-B.md), [development setup](docs/DEVELOPMENT.md), the [132-slice native roadmap](docs/ROADMAP-NATIVE-OFFLINE-1.0.md) and [Slice A acceptance](docs/SLICE-0.1-A.md).

## Release focus

- Windows and Android **offline** single-player first; local saves and AI, no logins, VPS or always-online requirement.
- Two original factions, complete skirmish, 20 authored campaign missions and 12 maps at 1.0.
- Multiplayer is optional after 1.0.
- Every new slice gets automated checks and a real-device acceptance gate. Never mark a planned game mechanic as complete based only on a menu mock.
