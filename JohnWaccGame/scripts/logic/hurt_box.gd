extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if (body != null && body != self.get_parent()):
		if (body.has_method("takeDamage")):
			body.call_deferred("takeDamage",1)
		else:
			body.get_node("AnimationPlayer").play("death")
