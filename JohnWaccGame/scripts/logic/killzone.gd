extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# if body exists
	if (body != null && body.has_method("set_dead")):
		# get the animation player
		body.call_deferred("set_dead")
		# if it exists, call the death animation
