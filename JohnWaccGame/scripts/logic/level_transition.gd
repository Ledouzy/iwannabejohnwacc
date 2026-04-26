extends Area2D

@export var next_scene_name: String = ""

func _on_body_entered(body: Node2D) -> void:
	scene_manager.change_scene(get_tree(), next_scene_name)
