# v0.1 Slice A — Native project bootstrap

## Scope
Create the root Godot 4.7.2 project, actual native main-menu game scene, versioned files and CI smoke checks. This is **not** the completed RTS, and the disabled Campaign/Skirmish entries do not imply any missions or combat exist.

## Acceptance
- [x] New Godot project isolated in `AlmightyTank/WebRTS-Native`; old Phaser repo unchanged.
- [x] Native main menu scene and responsive layout implemented.
- [x] Pinned engine version and GitHub Actions workflow written.
- [x] Headless menu smoke test implemented.
- [x] Native CI proves import, script parsing, scene startup and UI smoke pass on GitHub (Linux and Windows headless jobs passed: [run 40993074632](https://github.com/AlmightyTank/WebRTS-Native/actions/runs/40993074632)).
- [ ] Windows physical/desktop editor launch manually verified.
- [ ] Slice A merged to `main` after all required gates.

## Manual smoke on Windows
1. Clone and open `project.godot` in Godot 4.7.2.
2. Press F5 and confirm a non-browser game window appears.
3. Resize the window; left menu panel and text should stay usable.
4. Press DEVELOPMENT STATUS and confirm the status text changes.
5. Verify Campaign and Skirmish are visibly disabled.
6. Press EXIT GAME, confirm the window closes.
7. Confirm no web server or internet connection was needed.

## Next slice
v0.1-B: scene architecture, state/navigation services and clean signal boundaries. Later in v0.1: settings, data contracts, Windows export and Android debug export.

**Record actual CI and device results here before checking off remaining gates.**
