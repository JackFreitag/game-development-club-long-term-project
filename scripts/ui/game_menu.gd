extends CanvasLayer

func _ready() -> void:
	Main.game_state_changed.connect(state_changed)

func state_changed(state : Main.game_states) -> void:
	match state:
		Main.game_states.Paused:
			self.show()
		Main.game_states.Active:
			self.hide()

func _on_menu_button_pressed(button: StringName) -> void:
	match button:
		'Resume':
			Main.set_gamestate(Main.game_states.Active)
		'Restart':
			get_tree().call_deferred('change_scene_to_file', str(get_tree().current_scene.scene_file_path))
		'Quit':
			get_tree().quit()
