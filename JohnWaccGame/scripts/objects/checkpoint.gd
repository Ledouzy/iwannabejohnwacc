extends Area2D


# Checkpoint - By Ledouzy
# Call the functions for checkpoints save when entering the area of the object.
# IMPORTANT: CHECKPOINTS NEEDS TO BE A CHILD OF AN OBJECT WITH POSITION 0


func _on_body_entered(body: Node2D) -> void:
	# save to the checkpoint slot
	save_system.checkpoint_save(self.position.x, self.position.y)
