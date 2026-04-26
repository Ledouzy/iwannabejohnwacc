extends Area2D

@export var next_level_name: String = ""
@onready var next_level = "res://scenes/levels/" + next_level_name + ".tscn"

func _on_body_entered(body: Node2D) -> void:
	print("entered zone, next level: " + next_level_name)
	get_tree().change_scene_to_file(next_level)
