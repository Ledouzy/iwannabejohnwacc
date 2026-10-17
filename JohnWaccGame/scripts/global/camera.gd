extends Camera2D

## Camera - By Ledouzy
## Camera controller script for Sidescroller
## Make the camera follow the player and adds an offset for better visibility


# player and offset
@export var player: CharacterBody2D
@export var CameraOffset = Vector2(24,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# if player exists and is not dead
	if player != null && !player.is_dead():
		# follows the position of the character with an offset
		position = Vector2(player.position.x + CameraOffset.x * int(player.get_direction()), player.position.y + CameraOffset.y)
