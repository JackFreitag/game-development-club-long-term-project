## Copyright: UNCG Game Development Club Long-term Project
extends Node2D

@onready var player : Player = $Player

func _ready() -> void:
	player.death.connect(reset)
	Main.set_gamestate(Main.game_states.Active)

func reset() -> void:
	await get_tree().create_timer(5).timeout
	get_tree().call_deferred('change_scene_to_file', str(get_tree().current_scene.scene_file_path))
