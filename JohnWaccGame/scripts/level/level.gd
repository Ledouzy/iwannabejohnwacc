extends Node2D

@export var music_name: String = ""
@export var bgs_name: String = ""
@export var level_id: int = 0

# reference to the player
@onready var player = $Player.get_player()

# reference to the in-game UI and logic
@onready var game_manager: Control = %GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# if the checkpoint is not for the correct level, save the checkpoint to the beginning of the stage
	if save_system.checkpoint_data.stage != level_id:
		save_system.checkpoint_save(player.position.x, player.position.y)
	# set the stage we are at in the save system
	save_system.current_data.stage = level_id
	
	# play the music for the stage
	if music_name == "" or bgs_name == null:
		audio_manager.stop_music()
	else:
		audio_manager.play_music(music_name)
		
	# play the bgs for the stage
	if bgs_name == "" or bgs_name == null:
		audio_manager.stop_bgs()
	else:
		audio_manager.play_bgs(bgs_name)
	
	# loads the checkpoint so that we start at the checkpoint when restarting
	save_system.checkpoint_load(player)
	
	# update the UI to reflect the checkpoint data
	game_manager._ready()
