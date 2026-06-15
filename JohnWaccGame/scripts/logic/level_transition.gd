extends Area2D

# the name of the next scene we want to load
@export var next_scene_name: String = ""
# the id of the stage we are going to
@export var next_stage_number: int = 0

func _on_body_entered(body: Node2D) -> void:
	# save the id of the next stage
	save_system.current_data.stage = next_stage_number
	# save
	save_system._save()
	# load next level
	scene_manager.change_scene(get_tree(), next_scene_name)
