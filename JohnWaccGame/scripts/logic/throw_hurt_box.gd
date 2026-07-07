extends "res://scripts/logic/hurt_box.gd"

@export var character_body: CharacterBody2D
@export var character_body2: CharacterBody2D # in case we have two character bodies


func _on_body_entered(body: Node2D) -> void:
	# if body is the player, don't do anything
	if body == character_body or body == character_body2:
		return
	# call the hurtbox version
	super(body)
	# make the enemy die
	if (body != null && body != self.get_parent()) && body != character_body:
		self.get_parent().get_node("AnimationPlayer").play("death")
