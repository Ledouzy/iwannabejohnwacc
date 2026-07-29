extends Area2D


# the name of the next scene we want to load
@export var next_scene_name: String = ""
@export var player: CharacterBody2D
@export var starting_coords: Vector2 = Vector2(0,0)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var inside = false


func _on_body_entered(body: Node2D) -> void:
	if body != self and body == player:
		inside = true
	
func _on_body_exited(body: Node2D) -> void:
	inside = false

func _process(delta: float) -> void:
	if inside and Input.is_action_pressed("door"):
		# do not load the checkpoint
		scene_manager.load_checkpoint = false

		animated_sprite.play("open")
		# save
		save_system._save()
		# load next level
		scene_manager.change_scene(get_tree(), next_scene_name, starting_coords)
		inside = false
