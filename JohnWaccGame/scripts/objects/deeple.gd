extends Area2D

# Deeple - By Ledouzy
# Handle Deeple collection logic


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	print("body of deeple entered")
	# basically just the same logic as coins
	animation_player.play("pickup")
	audio_manager.play_sfx("Deeple", 0, position)
	
	#TODO: Add logic for deeple collection
