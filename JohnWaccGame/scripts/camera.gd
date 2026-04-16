extends Camera2D
@onready var player: CharacterBody2D = $"../Player"
@export var CameraOffset = 16

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !player.is_dead():
		position = Vector2(player.position.x + CameraOffset * int(player.get_direction()), player.position.y)
