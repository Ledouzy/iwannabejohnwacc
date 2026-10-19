extends Area2D

@export var cutscene_name: String = ""
@export var next_scene: String = ""
@export var cutscene_flag: String = ""
@export var start_coords: Vector2 = Vector2(0,0)

func _on_body_entered(body: Node2D) -> void:
	if global_manager.get_flag(cutscene_flag):
		return
	global_manager.set_flag(cutscene_flag, true)
	global_manager.cutscene_starting_coordinates = start_coords
	scene_manager.load_cutscene(cutscene_name, self.get_tree(), next_scene)
