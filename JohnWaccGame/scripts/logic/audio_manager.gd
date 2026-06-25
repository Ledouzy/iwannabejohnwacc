extends Node


# music streams
var active_music_stream: AudioStreamPlayer
var active_sound_stream: AudioStreamPlayer2D
var active_ui_stream: AudioStreamPlayer
var active_bgs_stream: AudioStreamPlayer

@export_group("Main")
## Node that stores the AudioStreamPlayer for music
@export var music: Node
## Node that stores the AudioStreamPlayer for sound
@export var sounds: Node
## Node that stores the AudioStreamPlayer for background sound (looping sounds)
@export var BGS: Node
## Node that stores the AudioStreamPlayer for ui sounds
@export var ui: Node

# UI sound effects to avoid having to specify the filename every time
@export_group("UI")
@export var confirm_sfx: AudioStreamPlayer
@export var move_sfx: AudioStreamPlayer
@export var back_sfx: AudioStreamPlayer


## plays the music with the corresponding audio name starting from the from_position.
## If restart is true, then the music will restart even if the music was already playing
func play_music(audio_name: String, from_position: float = 0.0, restart: bool = false, fadeout: bool = true) -> void:
	# if the music is already playing and restart is false, then return
	if !restart and active_music_stream and active_music_stream.name == audio_name:
		return
	
	# if changing music, then fade out and stop music
	elif active_music_stream and active_music_stream.name != audio_name:
		if fadeout:
			# create a tween to interpolate the fade out
			var tween = get_tree().create_tween()
			tween.tween_property(active_music_stream, "volume_linear", 0, 1.0)
			# wait until the fade out is complete
			await get_tree().create_timer(1.0).timeout
			
			# does not work for some reason, I will leave it in case
			active_music_stream.volume_db = 0.0
		# stop the music
		active_music_stream.stop()
		
	# get the audio stream for the music we want to play
	active_music_stream = music.get_node(audio_name)
	
	# check if we found the stream
	if !active_music_stream:
		print("error: music doesn't exist")
		return
	
	# reset the audio volume to 0.0 (they're all configured to 0.0 db)
	active_music_stream.volume_db = 0.0
	# play the audio
	active_music_stream.play(from_position)


## stops music
func stop_music(fadeout: bool = true):
	if !active_music_stream:
		return
	if fadeout:
		# create a tween to interpolate the fade out
		var tween = get_tree().create_tween()
		tween.tween_property(active_music_stream, "volume_linear", 0, 1.0)
		# wait until the fade out is complete
		await get_tree().create_timer(1.0).timeout
		
		# does not work for some reason, I will leave it in case
		active_music_stream.volume_db = 0.0
	
	# stop the music
	active_music_stream.stop()
	active_music_stream = null


## plays looping sound effects (Ex. Rain), works the same as music but without the fadeout
func play_bgs(audio_name: String, from_position: float = 0.0, restart: bool = false) -> void:
	# if the bgs is already playing and restart is false, then return
	if !restart and active_bgs_stream and active_bgs_stream.name == audio_name:
		return
	
	# if changing bgs, then stop bgs
	elif active_bgs_stream and active_bgs_stream.name != audio_name:
		# stop the bgs
		active_bgs_stream.stop()
	
	# get the audio stream for the bgs we want to play
	active_bgs_stream = BGS.get_node(audio_name)
	
	# check if we found the stream
	if !active_bgs_stream:
		print("error: bgs doesn't exist")
		return
	
	# play the audio
	active_bgs_stream.play(from_position)


## stops bgs
func stop_bgs():
	if !active_bgs_stream:
		return
	active_bgs_stream.stop()
	active_bgs_stream = null


## plays the sfx with the corresponding audio name starting from the from_position.
## the audio will play from the sound_position and get gradually quieter the farther away
func play_sfx(audio_name: String, from_position: float = 0.0, sound_position: Vector2 = Vector2(0,0)) -> void:
	# get the audio stream for the sound we want to play
	active_sound_stream = sounds.get_node(audio_name)
	
	# check if we found the stream
	if !active_sound_stream:
		print("error: sound doesn't exist")
		return
	
	# change the position of the sound stream
	active_sound_stream.position = sound_position
	# play the sound
	active_sound_stream.play(from_position)


## plays the sfx with the corresponding audio name starting from the from_position.
## the audio will play from the sound_position and get gradually quieter the farther away
func play_ui_sfx(audio_name: String, from_position: float = 0.0) -> void:
	# get the audio stream for the sound we want to play
	active_ui_stream = ui.get_node(audio_name)
	
	# check if we found the stream
	if !active_ui_stream:
		print("error: ui sound doesn't exist")
		return
	
	# play the sound
	active_ui_stream.play(from_position)


## plays the ui confirm sfx
func play_ui_confirm() -> void:
	confirm_sfx.play()
	
	
## plays the ui move sfx
func play_ui_move() -> void:
	move_sfx.play()
	
	
## plays the ui back sfx
func play_ui_back() -> void:
	back_sfx.play()
