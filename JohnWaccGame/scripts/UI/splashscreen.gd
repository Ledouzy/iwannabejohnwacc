extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# loads the title screen
	scene_manager.go_to_title(get_tree())
