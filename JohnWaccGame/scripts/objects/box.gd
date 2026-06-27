extends RigidBody2D

## Box - By Ledouzy
## Generic Box that can be pushed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# snaps position to 0 normally i kinda copied this code
	if abs(linear_velocity.x) <= 1 and abs(linear_velocity.y) <= 1:
		position = position.snapped(Vector2.ONE*1)
	
	#linear_velocity = linear_velocity.move_toward(Vector2(0,0), delta*1000)
