## Copyright: UNCG Game Development Club Long-term Project
extends Node

#region INIT

func  _enter_tree() -> void:
	check_cmd_args()
	set_min_win_size()
	Main.game_state_changed.connect(_on_game_state_changed)
	
	if not OS.get_name() == "Windows" and not OS.get_name() == "macOS":
		print('Display: ' + DisplayServer.get_name())
	
	print("")
	
	if OS.get_cmdline_args().has("--keep-active"): return
	get_window().focus_entered.connect(_on_window_focus_changed.bind(true))
	get_window().focus_exited.connect(_on_window_focus_changed.bind(false))

func set_min_win_size() -> void:
	await get_tree().process_frame
	var min_win_size : Vector2 = Vector2i(1152,648) * get_viewport().content_scale_factor
	if DisplayServer.window_get_size() < Vector2i(min_win_size):
		DisplayServer.window_set_size(min_win_size)
		DisplayServer.window_set_position(
			Vector2i(DisplayServer.screen_get_position(DisplayServer.window_get_current_screen())) + 
			Vector2i(DisplayServer.screen_get_size()*0.5 - DisplayServer.window_get_size()*0.5)
		)
	DisplayServer.window_set_min_size(min_win_size)

func check_cmd_args() -> void:
	var arguments := {}
	for argument : String in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	await get_tree().physics_frame
	
	for key : String in arguments:
		if !arguments[key].is_empty():
			match key:
				"ui-scale":
					get_viewport().content_scale_factor = arguments[key].to_float()
				"vp-scale":
					var vp_scale = arguments[key].to_float()
					vp_scale = clamp(vp_scale,0.2,2)
					get_viewport().scaling_3d_scale = vp_scale
				"max-fps":
					Engine.max_fps = arguments[key].to_int()
					Main.current_fps = arguments[key].to_int()
	
	if OS.get_cmdline_args().has("--show-fps"):
		Main.display_fps.call_deferred()
	
	if OS.get_cmdline_args().has("--borderless"):
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,true)

#endregion

#region INPUT

func _input(event : InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F10: Main.fullscreen(DisplayServer.WINDOW_MODE_FULLSCREEN)
		if event.keycode == KEY_F11: Main.fullscreen(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		if event.keycode == KEY_F1: Main.display_fps.call_deferred()
		
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_PAUSE:
			state_switch()
		
	if event is InputEventJoypadButton:
		if event.pressed and event.button_index == 6:
			state_switch()
		Main.gamepad_id = event.device
	elif event is InputEventJoypadMotion:
		Main.gamepad_id = event.device

func state_switch() -> void:
	match Main.game_state:
		Main.game_states.Active:
			Main.set_gamestate.call_deferred(Main.game_states.Paused)
		Main.game_states.Paused:
			Main.set_gamestate.call_deferred(Main.game_states.Active)

#endregion

#region EVENTS

func _on_game_state_changed(state : Main.game_states) -> void:
	match state:
		Main.game_states.Paused, Main.game_states.Paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Main.game_states.Active:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_window_focus_changed(has_focus : bool) -> void:
	if has_focus:
		OS.low_processor_usage_mode = false
		DisplayServer.screen_set_keep_on(true)
		Engine.max_fps = Main.current_fps
	else:
		if Main.game_state == Main.game_states.Active:
			Main.set_gamestate(Main.game_states.Paused)
		if !OS.low_processor_usage_mode:
			Main.current_fps = Engine.max_fps
		
		Engine.max_fps = 10
		OS.low_processor_usage_mode = true
		DisplayServer.screen_set_keep_on(false)

#endregion
