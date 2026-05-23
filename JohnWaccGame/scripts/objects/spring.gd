extends Node2D

@export var spring_jump_height = Vector2(0.0,-300.0)
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_area_body_entered(body: Node2D) -> void:
	if body == null:
		return
	if body.has_method("spring_jump"):
		body.call_deferred("spring_jump", spring_jump_height)
		animation_player.play("jump")
		audio_manager.play_sfx("Spring", 0.0, position)
