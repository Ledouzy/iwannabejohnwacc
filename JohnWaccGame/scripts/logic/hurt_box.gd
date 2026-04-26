extends Area2D

@export var damage = 1
var target: Node2D

func _on_body_entered(body: Node2D) -> void:
	print("enter")
	if (body != null && body != self.get_parent()):
		if (body.has_method("take_damage")):
			body.call_deferred("take_damage",damage)
			target = body
			print("changed target")
		else:
			if body.has_node("AnimationPlayer"):
				var x = body.get_node("AnimationPlayer")
				if x != null:
					x.play("death")
					
func _physics_process(delta: float) -> void:
	if target != null:
		print("take damage!")
		target.call_deferred("take_damage",damage)

func _on_body_exited(body: Node2D) -> void:
	print("exit")
	if body == target:
		target = null
