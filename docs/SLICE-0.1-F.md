# v0.1 Slice F — Godot CI and native validation

## Scope
Make the native project continuously verifiable in a fresh checkout. CI must
import and parse the project, run headless tests, validate the asset layout,
check a Windows export, and retain useful artifacts when a job fails.

## Implementation
- [x] Pinned Godot 4.7.2 Linux and Windows CI jobs.
- [x] Headless import and script/scene parse checks.
- [x] Full native regression coverage, including the Slice E command contract.
- [x] Asset/project layout validation for required native directories and scenes.
- [x] Windows Desktop export preset and CI build check.
- [x] Linux logs and Windows build/log artifacts retained with `if: always()`.

## Compatibility notes
- CI remains offline at runtime; the workflow downloads only the pinned Godot
  executable/export templates needed to build and test the project.
- The Windows export uses the Compatibility renderer and x86_64 architecture.
- Export artifacts are validation outputs, not a release claim; signing,
  installer packaging, Android export, and device testing remain later slices.

## Local acceptance
Install Godot 4.7.2 and run the commands in `docs/DEVELOPMENT.md`. On a machine
with the Windows export template installed, run:

```sh
godot --headless --path . --export-release "Windows Desktop" build/Poly-Warfront.exe
```
