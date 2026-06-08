extends "res://scripts/logic/hurt_box.gd"

@onready var character_body: CharacterBody2D = $"../CharacterBody2D"

func _on_body_entered(body: Node2D) -> void:
	if body == character_body:
		return
	super(body)
	if (body != null && body != self.get_parent()) && body != character_body:
		self.get_parent().get_node("AnimationPlayer").play("death")
