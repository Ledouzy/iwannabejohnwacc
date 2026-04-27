extends Area2D

@export var damage = 1
var target: Node2D

func _on_body_entered(body: Node2D) -> void:
	if (body != null && body != self.get_parent()):
		if (body.has_method("take_damage")):
			body.call_deferred("take_damage",damage)
			target = body
		else:
			if body.has_node("AnimationPlayer"):
				var x = body.get_node("AnimationPlayer")
				if x != null:
					x.play("death")
					
func _physics_process(delta: float) -> void:
	if target != null:
		target.call_deferred("take_damage",damage)

func _on_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
