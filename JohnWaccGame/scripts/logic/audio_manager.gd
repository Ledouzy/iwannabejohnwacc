extends Node

var active_music_stream: AudioStreamPlayer
var active_sound_stream: AudioStreamPlayer2D

@export_group("Main")
@export var music: Node
@export var sounds: Node
@export_group("UI")
@export var confirm_sfx: AudioStreamPlayer
@export var move_sfx: AudioStreamPlayer
@export var back_sfx: AudioStreamPlayer

func play_music(audio_name: String, from_position: float = 0.0, restart: bool = false) -> void:
	if !restart and active_music_stream and active_music_stream.name == audio_name:
		return
	elif active_music_stream and active_music_stream.name != audio_name:
		active_music_stream.stop()
	active_music_stream = music.get_node(audio_name)
	active_music_stream.play(from_position)

func play_sfx(audio_name: String, from_position: float = 0.0, sound_position: Vector2 = Vector2(0,0)) -> void:
	active_sound_stream = sounds.get_node(audio_name)
	active_sound_stream.position = sound_position
	active_sound_stream.play()
	
func play_ui_confirm() -> void:
	confirm_sfx.play()
	
func play_ui_move() -> void:
	move_sfx.play()
	
func play_ui_back() -> void:
	back_sfx.play()
