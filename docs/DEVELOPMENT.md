# Native development setup

## Versions
- Godot **4.7.2 stable** standard editor, GDScript (no .NET or C# required).
- Rendering baseline: Compatibility renderer, to facilitate early PC and Android low-spec testing.
- Game project lives at repository root; no browser wrapper, no npm dependency and no hosted backend.

## Run locally
1. Install Godot 4.7.2 and clone this repository.
2. Open `project.godot` in the Godot editor.
3. Press **F5** to launch the game window.
4. Click **DEVELOPMENT STATUS** to navigate to the second screen, then **BACK TO MAIN MENU**. Gameplay options are deliberately disabled.

## Headless validation
```sh
godot --headless --editor --path . --import --quit
godot --headless --path . res://tests/smoke.tscn
godot --headless --path . res://tests/architecture.tscn
godot --headless --path . --quit-after 10
```

Native CI performs all three with the same pinned engine version. These are bootstrap tests, **not** proof of Windows installer quality, Android hardware compatibility or a full 3D gameplay loop.

## Repository layout
- `project.godot` — application settings, autoloads and entry scene.
- `core/` — game state, navigation and event bus services.
- `assets/` — local original resources, organized by asset type.
- `scenes/` — native Godot scenes.
- `scripts/` — native UI and eventual game systems.
- `tests/` — headless checks.
- `docs/ROADMAP-NATIVE-OFFLINE-1.0.md` — master development plan.
- `.github/workflows/native-ci.yml` — native CI, no web stack.

## Platform policy
Windows game window is the first target. Android orientation, gesture mapping, APK export and physical-device checks are later steps in the v0.1 milestone. No network services are required to run the main scene. A shipped build is **not** claimed until export and device validation pass.

## Asset and licensing rules
Use original game art, music, voice and fiction. Do not copy Red Alert 2 or other copyrighted game content. Keep third-party licenses with imported assets and document source/usage.
