extends CharacterBody2D

# Movement Parameters
@export var SPEED = 90
var speedMult = 1.0
@export var JUMP_VELOCITY = -180.0
@export var MAX_FALL_VELOCITY = 300
@export var MAX_JUMPS = 1 # number of jumps
var jumps = MAX_JUMPS # number of jumps left
var dir = 1 # direction for camera mostly

# pickup/throw objects
var pickedUp

# animation flags
var jumpanim = true # play the animation once
var deathanim = false
var pickupanim = false
var waitforanimationend = false
var skipMoveProcess = false

# Death Flags
@export var dead = false

# Component references
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jumpSound: AudioStreamPlayer = $Jump
@onready var throw_rayCast: RayCast2D = $RayCast2D
#@onready var node: Node2D = $AnimatedSprite2D/Node2D

# Set the bools for true so that we can call from other scripts
func set_dead():
	dead = true
	deathanim = true

# returns value of dead
func is_dead() -> bool:
	return dead
	
# returns direction
func get_direction() -> int:
	return dir
	
# throw logic

func pickUp() -> bool:
	var object = throw_rayCast.get_collider()
	if object == null:
		return false
	if object.has_method("pickedUp"):
		object.call("pickedUp", self)
		pickedUp = object
		return true
	return false
	
	
func throw() -> void:
	if pickedUp == null:
		return
	if pickedUp.has_method("thrown"):
		pickedUp.call("thrown")

func _physics_process(delta: float) -> void:
	# When die
	if (dead):
		# first play the death animation once
		if (deathanim):
			animated_sprite.play("PlayerDeath")
			deathanim = false
			skipMoveProcess = true
			waitforanimationend = true
		#return # skip the entire physics calculation
		
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
		
	# pickup logic
	if Input.is_action_just_pressed("pick") && pickupanim == false && !waitforanimationend && is_on_floor():
		pickupanim = true
		waitforanimationend = true
		skipMoveProcess = true
		animated_sprite.play("PlayerPickup")
		velocity.x = 0
		await get_tree().create_timer(0.8).timeout
		if !pickUp():
			pickupanim = false
			animated_sprite.play("PlayerShrug")
			await get_tree().create_timer(0.6).timeout
		waitforanimationend = false
		skipMoveProcess = false
	# throw logic
	if Input.is_action_just_pressed("pick") && pickupanim == true && !waitforanimationend:
		pickupanim = false
		waitforanimationend = true
		animated_sprite.play("PlayerThrow")
		throw()
		await get_tree().create_timer(0.4).timeout
		waitforanimationend = false
	
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
		dir = -1
		animated_sprite.flip_h = true
		#node.position = Vector2(-16,8)
	elif (direction > 0):
		dir = 1
		#node.position = Vector2(16,8)
		animated_sprite.flip_h = false
		
	if !waitforanimationend:
		# Play animations
		if is_on_floor():
			jumpanim = true
			jumps = MAX_JUMPS
			if direction == 0:
				if (pickupanim):
					animated_sprite.play("PlayerPickupIdleSide")
				else:
					animated_sprite.play("PlayerIdleSide")
			else:
				if (pickupanim):
					animated_sprite.play("PlayerPickupWalkSide")
				else:
					animated_sprite.play("PlayerWalkSide")
		else:
			if jumpanim:
				jumpanim = false
				if (pickupanim):
					animated_sprite.play("PlayerPickupJumpSide")
				else:
					animated_sprite.play("PlayerJumpSide")
			
	if !skipMoveProcess:
		# Apply Movement
		
		if direction:
			velocity.x = direction * SPEED * speedMult
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	move_and_slide()
