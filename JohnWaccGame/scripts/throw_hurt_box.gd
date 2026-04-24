extends "res://scripts/hurt_box.gd"

func _on_body_entered(body: Node2D) -> void:
	super(body)
	if (body != null && body != self.get_parent()):
		self.get_parent().get_node("AnimationPlayer").play("death")
