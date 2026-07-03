extends Node2D


# Sound Object - By Ledouzy
# for when you need to play a sfx but you can't call something from the audio manager


func play_sfx(name: String):
	audio_manager.play_sfx(name, 0.0, position)
