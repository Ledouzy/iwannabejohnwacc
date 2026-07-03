extends base_button

# the id of the level it will load
@export var level_id: int


func _on_level_button_pressed() -> void:
	# load the level corresponding to level_id
	scene_manager.load_level(level_id)
