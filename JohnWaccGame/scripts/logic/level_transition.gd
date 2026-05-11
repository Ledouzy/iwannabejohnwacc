extends Area2D

@export var next_scene_name: String = ""
@export var next_stage_number: int = 0

func _on_body_entered(body: Node2D) -> void:
	save_system.current_data.stage = next_stage_number
	save_system._save()
	scene_manager.change_scene(get_tree(), next_scene_name)
