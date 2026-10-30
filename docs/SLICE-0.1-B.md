# v0.1 Slice B — Scene architecture

## Delivered on feature branch
- [x] Persistent AppRoot and full-rect ScreenHost.
- [x] Three startup-ordered autoload services: EventBus, GameState, SceneRouter.
- [x] Route registry, history, back/reset, safe rejection of invalid routes, detach on root disposal.
- [x] Real second Development Status screen with a Back button.
- [x] Native main menu integrates through navigation events; incomplete game modes remain disabled.
- [x] Local asset directory layout and conventions documented.
- [x] Headless state/navigation/lifecycle regression tests and UI smoke test added.
- [ ] Latest branch CI passed on Windows and Linux.
- [ ] Manual visual boot/navigation/back and exit verified on Windows.
- [ ] Slice B merged into main after acceptance gates.

## Playable test
1. Open `project.godot` in Godot 4.7.2; run F5.
2. MainMenu should be visible in its own native game window.
3. Select DEVELOPMENT STATUS; see a distinct screen showing current phase and "Slice B".
4. Click BACK TO MAIN MENU; original menu appears without spawning another window.
5. Repeat three times; navigation should stay responsive and not accumulate screens.
6. Campaign and Skirmish remain visibly disabled. EXIT GAME closes the window.
7. No web server, internet connection, or browser is needed.

## Automated coverage
- Initial attach and state defaults, invalid route/state guards, event count and back history.
- Prevent history duplication, mutable history leakage and duplicate screen children.
- Scene disposal clears router pointers; a fresh root can attach after disposal.
- Session lifecycle transitions, invalid phase rules and snapshot isolation.

**Status:** Implementation pushed for review. Do not check off final gates until current CI and Windows UI acceptance succeed.

### CI test runner note
The regression suites run via `tests/*.tscn` scenes (not `--script` standalone SceneTree scripts), so engine autoloads initialize as they do during actual gameplay. Both Windows and Linux workflows explicitly verify PASS markers and reject Godot script/parse errors.
