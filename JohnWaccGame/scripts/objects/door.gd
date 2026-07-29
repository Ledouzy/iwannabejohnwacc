extends Area2D


# the name of the next scene we want to load
@export var next_scene_name: String = ""
@export var player: CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var inside = false


func _on_body_entered(body: Node2D) -> void:
	print("body: ", body)
	if body != self and body == player:
		print("inside")
		inside = true
	
func _on_body_exited(body: Node2D) -> void:
	print("outside")
	inside = false

func _process(delta: float) -> void:
	if inside and Input.is_action_pressed("door"):
		print("clopen")
		animated_sprite.play("open")
		# save
		save_system._save()
		# load next level
		scene_manager.change_scene(get_tree(), next_scene_name)
		inside = false
