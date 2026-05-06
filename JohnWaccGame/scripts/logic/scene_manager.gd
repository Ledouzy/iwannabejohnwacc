class_name SceneManager extends CanvasLayer

@onready var animation: AnimationPlayer = $TransitionAnimation

func change_scene(from, to_scene_name: String) -> void:
	var next_level = "res://scenes/levels/" + to_scene_name + ".tscn"
	animation.play("fade_out")
	await animation.animation_finished
	get_tree().call_deferred("change_scene_to_file", next_level)
	animation.play("fade_in")
	await animation.animation_finished
	
func load_level(level_id: int):
	var next_level = "res://scenes/levels/level" + str(level_id) + ".tscn"
	animation.play("fade_out")
	await animation.animation_finished
	get_tree().call_deferred("change_scene_to_file", next_level)
	animation.play("fade_in")
	await animation.animation_finished
	
func go_to_title(from) -> void:
	var next_level = "res://scenes/UI/title_screen.tscn"
	animation.play("fade_out")
	await animation.animation_finished
	get_tree().call_deferred("change_scene_to_file", next_level)
	animation.play("fade_in")
	await animation.animation_finished
