extends Area2D

@export var damage = 1 # damage that the attack will do
var target: Node2D # the entity that will receive the damage
var direction = 1 # direction that the knockback will be applied

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _on_body_entered(body: Node2D) -> void:
	if (body != null && body != self.get_parent()):
		if (body.has_method("take_damage")):
			if body.position.x < self.get_parent().position.x:
				direction = -1
			else:
				direction = 1
			body.call_deferred("take_damage",damage, direction)
			target = body
		else:
			if body.has_node("AnimationPlayer"):
				var x = body.get_node("AnimationPlayer")
				if x != null:
					x.play("death")

func _physics_process(delta: float) -> void:
	if collision_shape != null and collision_shape.disabled == true and target != null:
		target = null
	if target != null:
		target.call_deferred("take_damage",damage, direction)

func _on_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
