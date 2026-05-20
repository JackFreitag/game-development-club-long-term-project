## Copyright: UNCG Game Development Club Long-term Project
extends Node

# Signals
signal game_state_changed (int : game_states)
signal refresh_settings ()
# Variables
enum game_states {Idle,Paused,Active}
var game_state := game_states.Active
var current_fps : int = Engine.max_fps
var gamepad_id : int = 0

#region INIT

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("Platform: " + OS.get_name())
	match OS.get_name(): # if we are on desktop systems load the desktop init script
		"Windows", "macOS", "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			var platform = Node.new()
			platform.process_thread_group = PROCESS_THREAD_GROUP_SUB_THREAD
			add_child(platform)
			platform.set_script(load("res://scripts/platforms/desktop.gd"))
		"Web":
			var platform = Node.new()
			add_child(platform)
			platform.set_script(load("res://scripts/platforms/web.gd"))
	
	if not OS.is_userfs_persistent() : push_error("File system persistence unavailable!")

func _enter_tree() -> void:
	if DisplayServer.get_name() == "headless" : get_tree().quit()
	get_viewport().disable_3d = true
	
	Engine.max_fps = clampi(ceil(DisplayServer.screen_get_refresh_rate()),0,300)
	current_fps = clampi(ceil(DisplayServer.screen_get_refresh_rate()),0,300)
	
	if DisplayServer.screen_get_max_scale() == 2.0: 
		get_viewport().content_scale_factor = 1.75

#endregion

#region EVENTS

func set_gamestate(state : game_states) -> void:
	if not state == game_state:
		game_state = state
		
		get_tree().paused = bool(state == game_states.Paused)
		
		game_state_changed.emit(state)

func fullscreen(mode : DisplayServer.WindowMode) -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(mode)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	await get_tree().create_timer(0.1).timeout
	refresh_settings.emit()

func display_fps() -> void:
	for child in get_children():
		if child.name == 'FPScounter':
			child.queue_free()
			return
	var frame_counter = load("res://ui/debug/fps_counter.tscn").instantiate()
	add_child(frame_counter)

#endregion
