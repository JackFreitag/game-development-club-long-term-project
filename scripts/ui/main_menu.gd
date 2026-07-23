extends Node

func _on_menu_button_pressed(action: StringName) -> void:
	match action:
		'Play':
			get_tree().call_deferred('change_scene_to_file', 'res://scenes/test_level.tscn')
			Main.set_gamestate(Main.game_states.Active)
		'Quit':
			get_tree().quit()
