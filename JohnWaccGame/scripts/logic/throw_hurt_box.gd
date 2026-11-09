extends "res://scripts/logic/hurt_box.gd"

@export var character_body: CharacterBody2D


func _on_body_entered(body: Node2D) -> void:
	# if body is the player, don't do anything
	if body == character_body:
		return
	# call the hurtbox version
	super(body)
	# make the enemy die
	if (body != null && body != self) && body != character_body:
		if self.get_parent().get_parent().has_method("take_damage"):
			self.get_parent().get_parent().call_deferred("take_damage", 2, Vector2(0,0))
