extends CharacterBody2D

# Movement Parameters
@export var SPEED = 90
var speedMult = 1.0
@export var JUMP_VELOCITY = -180.0
@export var MAX_FALL_VELOCITY = 300
@export var MAX_JUMPS = 1 # number of jumps
var jumps = MAX_JUMPS # number of jumps left

# Death Flags
@export var dead = false
var deathanim = false

# Component references
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jumpSound: AudioStreamPlayer = $Jump
@onready var node: Node2D = $AnimatedSprite2D/Node2D

# Set the bools for true so that we can call from other scripts
func set_dead():
	dead = true
	deathanim = true

func _physics_process(delta: float) -> void:
	# When die
	if (dead):
		# first play the death animation once
		if (deathanim):
			animated_sprite.play("death")
			deathanim = false
		return # skip the entire physics calculation
		
	# Add the gravity.
	if not is_on_floor():
		if velocity.y < MAX_FALL_VELOCITY:
			velocity += get_gravity() * delta * 0.5

	# Handle jump.
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY * 0.25
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() || jumps > 1) :
		jumps -= 1
		jumpSound.play()
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	
	# check if running
	
	if Input.is_action_just_pressed("run"):
		print("running!")
		speedMult = 1.5
	elif Input.is_action_just_released("run"):
		speedMult = 1.0
	
	# Flip sprite
	if (direction < 0):
		animated_sprite.flip_h = true
		node.position = Vector2(-16,8)
	elif (direction > 0):
		node.position = Vector2(16,8)
		animated_sprite.flip_h = false
		
		
	# Play animations
	if is_on_floor():
		jumps = MAX_JUMPS
		if direction == 0:
			animated_sprite.play("PlayerIdleSide")
		else:
			animated_sprite.play("PlayerWalkSide")
	else:
		animated_sprite.play("PlayerJumpSide")
		
	# Apply Movement
	
	if direction:
		velocity.x = direction * SPEED * speedMult
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
