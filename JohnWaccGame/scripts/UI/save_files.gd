extends Control


func _on_play_button_pressed() -> void:
	scene_manager.change_scene(get_tree(), "game")
