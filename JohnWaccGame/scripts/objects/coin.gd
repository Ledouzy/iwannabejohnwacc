extends Area2D

@onready var game_manager: Control = $"../../../../GameManager"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	# if the coin is not placed in a tilemap it might bug
	if game_manager == null:
		game_manager = %GameManager
	game_manager.add_point()
	animation_player.play("pickup")
	audio_manager.play_sfx("Coin", 0, position)
