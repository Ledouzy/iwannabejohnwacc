extends Node2D

@onready var player: player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	save_system.current_data.stage = 1
	audio_manager.play_music("StarLightZone")
	# create a new checkpoint save at the start of the level
	save_system.checkpoint_save(player.position.x, player.position.y)
