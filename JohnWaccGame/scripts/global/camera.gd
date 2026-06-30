extends Camera2D

## Camera - By Ledouzy
## Camera controller script for Sidescroller
## Make the camera follow the player and adds an offset for better visibility


# player and offset
@onready var player: CharacterBody2D = $"../Player".get_player()
@export var CameraOffset = 24


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# if player exists and is not dead
	if player != null && !player.is_dead():
		# follows the position of the character with an offset
		position = Vector2(player.position.x + CameraOffset * int(player.get_direction()), player.position.y)
