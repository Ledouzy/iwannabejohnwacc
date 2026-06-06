extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	print("body of deeple entered")
	# if the coin is not placed in a tilemap it might bug
	animation_player.play("pickup")
	audio_manager.play_sfx("Coin", 0, position)
	
	#TODO: Add logic for deeple collection
