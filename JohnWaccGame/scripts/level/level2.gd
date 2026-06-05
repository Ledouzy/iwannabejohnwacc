extends Node2D

@onready var player = $Player.get_player()
@onready var game_manager: Control = %GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if save_system.checkpoint_data.stage != 2:
		save_system.checkpoint_save(player.position.x, player.position.y)
	save_system.current_data.stage = 2
	audio_manager.play_music("StarlightZone")
	# create a new checkpoint save at the start of the level
	save_system.checkpoint_load(player)
	game_manager._ready()
