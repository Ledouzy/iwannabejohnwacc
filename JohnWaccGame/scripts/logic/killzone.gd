extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# if body exists
	if (body != null):
		# get the animation player
		var temp = body.get_node("AnimationPlayer")
		# if it exists, call the death animation
		if temp != null:
			temp.play("death")
