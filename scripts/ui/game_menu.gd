extends CanvasLayer

func _ready() -> void:
	Main.game_state_changed.connect(state_changed)

func state_changed(state : Main.game_states) -> void:
	match state:
		Main.game_states.Paused:
			self.show()
		Main.game_states.Active:
			self.hide()
