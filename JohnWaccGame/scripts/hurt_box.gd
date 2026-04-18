extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("Enemy Hit!")
	if (body != null && body != self.get_parent()):
		body.get_node("AnimationPlayer").play("death")
