extends Camera2D
@onready var player: CharacterBody2D = $"../Player"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if player != null && !player.is_dead():
		position = Vector2(player.position.x, player.position.y)
