extends CharacterBody2D

# Movement Parameters
# Speed
@export var SPEED = 90 # base speed value
@export var RUN_MULT = 1.5 # Sprint multiplier
var speedMult = 1.0 # mults the speed by this constant, changes if sprinting
# Jump
@export var JUMP_VELOCITY = -180.0 # How high you jump
@export var MAX_FALL_VELOCITY = 300 # How fast you fall
@export var MAX_JUMPS = 1 # number of jumps
var jumps = MAX_JUMPS # number of jumps left
# direction
var dir = 1 # direction of the player

# pickup/throw objects
var pickedUp # stores the object that you picked up

# animation flags
var jumpanim = false # play the animation once
var deathanim = false # play the animation once
var pickupanim = false # will change to pickup variants of animations
var waitforanimationend = false # stop other animations from playing until finished with current
var skipMoveProcess = false # stop the calculations for user input movement, letting only gravity affect player

# Death Flags
@export var dead = false # indicates that the player is dead

# Component references
@onready var player_body: CharacterBody2D = $"."
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jumpSound: AudioStreamPlayer = $Jump
@onready var throw_rayCast: RayCast2D = $RayCast2D
@onready var death_timer: Timer = $DeathTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## Getter: returns value of dead, i.e. is player dead or not
func is_dead() -> bool:
	return dead
	
## Setter: Set the bools for true so that we can call from other scripts
func set_dead():
	# we are dead
	dead = true 
	
	# we play death animation
	
	deathanim = true 
	print("You died!") # debug message
	
	# start the (2) seconds timer before reload
	death_timer.start()
	
## when death timer runs out, reload current scene
func _on_death_timer_timeout() -> void:
	get_tree().reload_current_scene()
	
## returns the direction, it's called dir since direction already existed
func get_direction() -> int:
	return dir
	
## handles picking up objects and enemies
func pickUp() -> bool:
	# get the enemy or object right below the player
	var object = throw_rayCast.get_collider()
	
	# check if that object exists and that it can be pickedUp
	# TODO: change so it checks for class throwable when that class is added
	
	if object == null:
		return false
	if object.has_method("pickedUp"):
		# call the pickedUp method on the object
		object.call("pickedUp", self)
		
		# set the pickedUp field to the object we picked up
		pickedUp = object
		return true
		
	return false

## Handles throwing objects and enemies
func throw() -> void:
	# check first if we do have an item that we picked up, and check if that method does have a thrown method
	# TODO: change so it checks for class throwable when that class is added
	if pickedUp == null:
		return
	if pickedUp.has_method("thrown"):
		# call the thrown method on the object
		pickedUp.call("thrown")
		
## Handles the playing of animations not specific to an action
func process_animation(direction) -> void:
	# grounded animation
	if is_on_floor():
		# we are not jumping and we can reset our number of jumps
		jumpanim = false
		jumps = MAX_JUMPS
		
		# if we are not moving, play the idle animation
		if direction == 0:
			# if we are holding an object/enemy, play the variant
			if (pickupanim):
				animated_sprite.play("PlayerPickupIdleSide")
			else:
				animated_sprite.play("PlayerIdleSide")
		# else, we are moving, play the walk animation
		else:
			# if we are holding an object/enemy, play the variant
			if (pickupanim):
				animated_sprite.play("PlayerPickupWalkSide")
			else:
				animated_sprite.play("PlayerWalkSide")
	# we are in the air
	else:
		if !jumpanim:
			# play the jump animation, but only once
			jumpanim = true
			
			# if we are holding an object/enemy, play the variant
			if (pickupanim):
				animated_sprite.play("PlayerPickupJumpSide")
			else:
				animated_sprite.play("PlayerJumpSide")

## call at fixed interval for physics calculations
func _physics_process(delta: float) -> void:
	# When dead
	if (dead):
		# play the death animation once
		if (deathanim):
			animated_sprite.play("PlayerDeath")
			deathanim = false
			
			# lock movement and animation
			skipMoveProcess = true
			waitforanimationend = true
		
	# Add the gravity.
	if not is_on_floor():
		if velocity.y < MAX_FALL_VELOCITY:
			velocity += get_gravity() * delta * 0.5

	# Jump Handling
	# If light tap, we decrease our velocity
	if Input.is_action_just_released("jump") and velocity.y < 0 && !waitforanimationend:
		# updates the velocity
		velocity.y = JUMP_VELOCITY * 0.25
	
	# If held, or first tapped we give full height, also handles multiple jumps
	if Input.is_action_just_pressed("jump") and (is_on_floor() && jumps >= 1) && !waitforanimationend :
		# removes 1 jump to number of jumps (jumps variable)
		jumps -= 1
		
		# play the jump sfx
		jumpSound.play()
		
		# updates the velocity
		velocity.y = JUMP_VELOCITY
		
	# Handles PickUp objects and enemies
	if Input.is_action_just_pressed("pick") && pickupanim == false && !waitforanimationend && is_on_floor():
		# indicates that we use pickup variants of animations
		pickupanim = true
		
		# stop animations and stop player from moving
		waitforanimationend = true
		skipMoveProcess = true
		
		# Play the animation for picking up
		animated_sprite.play("PlayerPickup")
		# TODO: Add sfx for pickup
		
		# freezes the player in place for the duration of the animation
		velocity.x = 0
		
		# waits for a fixed amount for the animation to play
		await get_tree().create_timer(0.8).timeout
		
		# tries to pickUp the item right below us
		if !pickUp():
			# if we did not pick anything up, or the object wasn't pickable (same shit really)
			# stop the animation
			pickupanim = false
			
			# makes the player shrug to waste his time
			animated_sprite.play("PlayerShrug")
			
			# wait for shrug animation end
			await get_tree().create_timer(0.6).timeout
			
		# allows animation to play and player to move again
		waitforanimationend = false
		skipMoveProcess = false
		
	# Handles throwing objects and enemies
	if Input.is_action_just_pressed("pick") && pickupanim == true && !waitforanimationend:
		# indicate that we aren't holding anything anymore and locks animations
		pickupanim = false
		waitforanimationend = true
		
		# Play the throw animation
		animated_sprite.play("PlayerThrow")
		
		# Throw the held object/enemy
		throw()
		
		# wait for throw to finish and then allows animation to play again
		await get_tree().create_timer(0.4).timeout
		waitforanimationend = false
		
	# Handles attacking, right now only for sword and on side
	# TODO: Handle attack in all direction if in air and 2 directions on the ground (up side down and up side respectively)
	if Input.is_action_just_pressed("attack") && !waitforanimationend:
		print("attack") # debug message
		
		# play the attack animation and locks animation for the length of the animation
		animation_player.play("attackSide")
		waitforanimationend = true
		await get_tree().create_timer(0.3).timeout
		waitforanimationend = false
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	
	# check if running
	if Input.is_action_just_pressed("run"):
		print("running!") # debug message
		
		# updates the speed multiplier with run speed
		speedMult = RUN_MULT
		
	elif Input.is_action_just_released("run"):
		# defaults back to 1 speed multiplier
		speedMult = 1.0
	
	# Flip sprite if changed direction
	if (direction < 0):
		# flip sprite if we changed direction
		if dir != -1:
			player_body.scale.x = -1
			
		# updates our direction
		dir = -1
	elif (direction > 0):
		# flip sprite if we changed direction
		if dir != 1:
			player_body.scale.x = -1
			
		# updates our direction
		dir = 1
	
	# animation handling
	if !waitforanimationend:
		process_animation(direction)
			
	if !skipMoveProcess:
		# Apply Movement
		if direction:
			velocity.x = direction * SPEED * speedMult
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	move_and_slide()
