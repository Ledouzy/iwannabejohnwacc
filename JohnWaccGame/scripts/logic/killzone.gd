extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if (body != null):
		var temp = body.get_node("AnimationPlayer")
		if temp != null:
			temp.play("death")
