extends Area2D

@onready var game_manager: Control = $"../../../../GameManager"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	# if the coin is not placed in a tilemap it might bug, so this is a fix for that
	if game_manager == null:
		game_manager = %GameManager
	# adds a coin to the UI
	game_manager.add_point()
	# plays the coin sound and the animation for picking up the coin
	animation_player.play("pickup")
	audio_manager.play_sfx("Coin", 0, position)
