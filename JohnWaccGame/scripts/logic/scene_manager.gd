class_name SceneManager extends CanvasLayer

var starting_coords: Vector2 = Vector2(0,0)
var load_checkpoint = true

@onready var animation: AnimationPlayer = $TransitionAnimation


# change the scene to the scene name specified (needs to be in the levels/ folder)
func change_scene(from, to_scene_name: String, new_coords: Vector2 = Vector2(0,0)) -> void:
	# get the path for the scene
	var next_level = "res://scenes/levels/" + to_scene_name + ".tscn"
	
	starting_coords = new_coords
	
	# pause game
	get_tree().paused = true
	
	# initiate fade out
	animation.play("fade_out")
	# wait for the end of the animation
	await animation.animation_finished
	
	# change scene to the specified scene
	get_tree().call_deferred("change_scene_to_file", next_level)
	
	# unpause game
	get_tree().paused = false
	
	# initiate fade in
	animation.play("fade_in")
	await animation.animation_finished


# reload the current screen
func reload_scene() -> void:
	# pause game
	get_tree().paused = true
	
	# initiate fade out
	animation.play("fade_out")
	# wait for the end of the animation
	await animation.animation_finished
	
	# reload the current scene
	get_tree().reload_current_scene()
	
	# unpause game
	get_tree().paused = false
	
	# initiate fade in
	animation.play("fade_in")
	await animation.animation_finished
	
	
# load a level, takes only the level id
func load_level(level_id: int):
	# get the path for the title screen
	var next_level = "res://scenes/levels/level" + str(level_id) + ".tscn"
	
	# pause game
	get_tree().paused = true
	
	# initiate fade out
	animation.play("fade_out")
	# wait for the end of the animation
	await animation.animation_finished
	
	# change the scene to the level
	get_tree().call_deferred("change_scene_to_file", next_level)
	
	# unpause game
	get_tree().paused = false
	
	# initiate fade in
	animation.play("fade_in")
	await animation.animation_finished
	
	
func go_to_title(from) -> void:
	# get the path for the title screen
	var next_level = "res://scenes/UI/title_screen.tscn"
	
	# pause game
	get_tree().paused = true
	
	# initiate fade out
	animation.play("fade_out")
	# wait for the end of the animation
	await animation.animation_finished
	
	# load the title screen
	get_tree().call_deferred("change_scene_to_file", next_level)
	
	# unpause game
	get_tree().paused = false
	
	animation.play("fade_in")
	await animation.animation_finished
