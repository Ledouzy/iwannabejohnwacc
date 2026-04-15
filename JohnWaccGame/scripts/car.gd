extends CharacterBody2D

@export var speed = 10
var direction = -1
@export var MAX_FALL_VELOCITY = 300
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# check for walls and change direction if yes
	if ray_cast_right.is_colliding():
		direction = 1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = -1
		animated_sprite.flip_h = false
	if ray_cast_left.is_colliding() && ray_cast_right.is_colliding():
		animated_sprite.play("CarIdleFront")
		pass
	else:
		animated_sprite.play("CarWalkSide")
		position.x += direction * delta * speed

func _physics_process(delta: float) -> void:
	# process gravity
	if not is_on_floor():
		if velocity.y < MAX_FALL_VELOCITY:
			velocity += get_gravity() * delta * 0.5
	move_and_slide()
