extends Area2D

@export var heal_amount: int = 1 # amount healed per tick
@export var heal_frequency: float = 1.0

var target: Array[Node2D] # the entities that will receive the healing
var timer: float = 0.0 # timer for when to heal

# the collision for the hurtbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _on_body_entered(body: Node2D) -> void:
	# if body is not the parent of the hurtbox
	if (body != null && body != self.get_parent()):
		# if it can get healed
		if body.has_method("heal_damage"):
			# call heal damage on the body
			body.call_deferred("heal_damage",heal_amount)
			
			# add the body to the targets
			target.append(body)


func _physics_process(delta: float) -> void:
	# if the hurtbox is disabled
	if collision_shape != null and collision_shape.disabled == true and target != null:
		# clear the list
		target.clear()
	
	# increment timer with time since last frame
	timer += delta
	
	# if timer is higher than the heal frequency
	if timer >= heal_frequency:
		# reset the counter
		timer = 0.0
		
		# heal the targets
		if !target.is_empty():
			# if it's not empty
			for t in target:
				# call heals damage on every target
				t.call_deferred("heal_damage", heal_amount)


func _on_body_exited(body: Node2D) -> void:
	# when exiting the body, remove it from the list
	target.erase(body)
