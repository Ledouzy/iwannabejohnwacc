extends Area2D

# IMPORTANT: CHECKPOINTS NOT BUT BE A CHILD OF SOMETHING THAT HAS POSITION NOT EQUAL TO 0

func _on_body_entered(body: Node2D) -> void:
	# save to the checkpoint slot
	save_system.checkpoint_save(self.position.x, self.position.y)
