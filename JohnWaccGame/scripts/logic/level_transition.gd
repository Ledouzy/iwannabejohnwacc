extends Area2D

@export var next_scene_name: String = ""

func _on_body_entered(body: Node2D) -> void:
	save_system.current_data.stage = 1
	save_system._save()
	scene_manager.change_scene(get_tree(), next_scene_name)
