extends Node2D

@onready var player: CharacterBody2D = $Player.get_player()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_manager.play_music("DivineBloodlines")
	save_system.checkpoint_load(player)
	save_system.current_data.stage = 0
