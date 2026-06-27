extends Camera2D

## Camera Topdown - By Ledouzy
## Camera controller script for Topdown
## Make the camera follow the player without an offset


@onready var player: CharacterBody2D = $"../Player".get_player()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# if player exists and is not dead
	if player != null && !player.is_dead():
		# follows the position of the character
		position = Vector2(player.position.x, player.position.y)
