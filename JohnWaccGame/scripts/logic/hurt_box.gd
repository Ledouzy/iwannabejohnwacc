extends Area2D

@export var damage = 1 # damage that the attack will do
var target: Array[Node2D] # the entity that will receive the damage
var direction = Vector2(1,0) # direction that the knockback will be applied

# the collision for the hurtbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# when a body enters the area
func _on_body_entered(body: Node2D) -> void:
	# if body is not the parent of the hurtbox
	if (body != null && body != self.get_parent()):
		# if it can take damage
		if (body.has_method("take_damage")):
			# get normal for the direction
			direction = self.get_parent().position.direction_to(body.position)
			print("self: ", self.get_parent().position)
			print("body: ", body.position)
			print("direction: ", direction)
			# call take damage on the body
			body.call_deferred("take_damage",damage, direction)
			# add the body to the targets
			target.append(body)
		else:
			# if body has animation player, assume it has death animation since we can't check
			if body.has_node("AnimationPlayer"):
				# get the animation player
				var x = body.get_node("AnimationPlayer")
				
				if x != null:
					# play the death animation
					x.play("death")

func _physics_process(delta: float) -> void:
	# if the hurtbox is disabled
	if collision_shape != null and collision_shape.disabled == true and target != null:
		# clear the list
		target.clear()
	if !target.is_empty():
		# if it's not empty
		for t in target:
			# call take damage on every target
			t.call_deferred("take_damage",damage, direction)

func _on_body_exited(body: Node2D) -> void:
	# when exiting the body, remove it from the list
	for t in target:
		if body == t:
			target.erase(t)
