extends Node
## Global typed cross-screen signals. UI requests navigation; SceneRouter owns routing.
## No scene should hold hard references to unrelated screens.

signal navigation_requested(route: StringName)
signal back_requested
signal route_changed(route: StringName, history_depth: int)
signal session_changed(snapshot: Dictionary)
signal notification_requested(message: String)
