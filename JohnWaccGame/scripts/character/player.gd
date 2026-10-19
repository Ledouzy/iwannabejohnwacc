extends Node2D

@onready var player: CharacterBody2D = $".."

# play a sound by calling the audio manager
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, player.position)
