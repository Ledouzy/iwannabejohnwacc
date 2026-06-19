extends Node2D

@export var spring_jump_height = Vector2(0.0,-300.0)
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_area_body_entered(body: Node2D) -> void:
	# if the body does not exist just return
	if body == null:
		return
	# if the body can be affected by a spring
	if body.has_method("spring_jump"):
		# call the method spring jump
		body.call_deferred("spring_jump", spring_jump_height)
		# play the animation for when someone jumps on the spring
		animation_player.play("jump")
		# play the sfx
		audio_manager.play_sfx("Spring", 0.0, position)
