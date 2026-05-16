extends base_button

@export var level_id: int

func _on_level_button_pressed() -> void:
	scene_manager.load_level(level_id)
