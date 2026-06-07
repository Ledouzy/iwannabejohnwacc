extends CharacterBody2D
class_name player_topdown

# Movement Parameters
# Speed
@export var SPEED = 10 ## base speed value
@export var SPEED_CAP = 120
@export var WALK_CAP = 45
@export var RUN_CAP = 80
@export var RUN_MULT = 1.5 ## Sprint multiplier
var speedMult = 1.0 ## mults the speed by this constant, changes if sprinting
# Jump
#@export var JUMP_VELOCITY = -200.0 ## How high you jump
#@export var MAX_FALL_VELOCITY = 300 ## How fast you fall
@export var MAX_JUMPS = 1 ## number of jumps        
@onready var jumps = MAX_JUMPS # number of jumps left
@export var MAXCOYOTETIME = .14 # max time in air before we can't jump anymore
var coyote_timer = 0
var can_jump = true

# deadzone
@export var deadzone = 0.25 ## min value before input is registered

# direction
var dir = 1 # direction of the player (N-0,E-1,S-2,W-3)
var side_dir = 1 # act as the old dir did
var lock_direction = false

# health related
@export var MAX_HEALTH = 10 ## max hp
@onready var health = MAX_HEALTH # number of hits before dying
var invulnerable = false
@onready var damage_timer: Timer = $DamageTimer ## invulnerability frames basically
#var healthLock : Mutex # lock for not taking damage until invul frames end

# pickup/throw objects
var pickedUp # stores the object that you picked up

# pushing blocks
@export var push_force = 10.0

# animation flags
var jumpanim = false # play the animation once
var deathanim = false # play the animation once
var pickupanim = false # will change to pickup variants of animations
var pushanim = false
var waitforanimationend = false # stop other animations from playing until finished with current
var skipMoveProcess = false # stop the calculations for user input movement, letting only gravity affect player

# Death Flags
@export var dead = false # indicates that the player is dead

# Component references
#@onready var game_manager: Control = %GameManager
@onready var player_body: CharacterBody2D = $"."
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var throw_rayCast: RayCast2D = $RayCastThrow
@onready var death_timer: Timer = $DeathTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blink_animation_player: AnimationPlayer = $BlinkAnimationPlayer
@onready var camera: Camera2D = $"../../Camera2D"

# ready just for camera lmao
func _ready() -> void:
	camera.position_smoothing_enabled = false
	camera.position = self.position
	
	# make sure one frame occurs with the position not smoothed
	await get_tree().create_timer(0.1).timeout
	camera.position_smoothing_enabled = true
	
	motion_mode = MOTION_MODE_FLOATING

## Getter: returns value of dead, i.e. is player dead or not
func is_dead() -> bool:
	return dead
	
## Setter: Set the bools for true so that we can call from other scripts
func set_dead():
	# set health to 0 so it doesn't look weird
	health = 0
	# we are dead
	dead = true 
	
	# we play death animation
	
	deathanim = true 
	print("You died!") # debug message
	
	# start the (2) seconds timer before reload
	death_timer.start()
	
## get value of health
func get_health() -> int:
	return health
	
## get value of MAX_HEALTH
func get_max_health() -> int:
	return MAX_HEALTH
	
## when death timer runs out, reload current scene
func _on_death_timer_timeout() -> void:
	save_system.checkpoint_load(self)
	scene_manager.reload_scene()

## proccess taking damage
#TODO: Implement direction knockback
func take_damage(damage, direction) -> void:
	if !invulnerable:
		invulnerable = true
		damage_timer.start()
		health -= damage
		health = max(health,0)
		if health <= 0:
			animation_player.play("death")
		else:
			animated_sprite.play("PlayerTakeDamage")
			
			skipMoveProcess = true
			waitforanimationend = true
			await animated_sprite.animation_finished
			skipMoveProcess = false
			waitforanimationend = false
			blink_animation_player.play("blink")
			await blink_animation_player.animation_finished
	
func _on_damage_timer_timeout() -> void:
	invulnerable = false
	
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
		
## Handles jumping on springs
func spring_jump(jump_height):
	# updates the velocity
	velocity = jump_height

## Handles the playing of animations not specific to an action
func process_animation(direction_x, direction_y) -> void:
	# grounded animation
	# if we are not moving, play the idle animation
	if direction_x == 0 && direction_y == 0:
		# if we are holding an object/enemy, play the variant
		match dir:
			0:
				animated_sprite.play("PlayerIdleFront")
			1:
				animated_sprite.play("PlayerIdleSide")
			2:
				animated_sprite.play("PlayerIdleBack")
			3:
				animated_sprite.play("PlayerIdleSide")
			_:
				print("Error: Direction isn't between 0 and 3")
	# else, we are moving, play the walk animation
	else:
		# if we are holding an object/enemy, play the variant
		if (pickupanim):
			animated_sprite.play("PlayerPickupWalkSide")
		else:
			match dir:
				0:
					if pushanim:
						animated_sprite.play("PlayerPushFront")
					else:
						animated_sprite.play("PlayerWalkFront")
				1:
					if pushanim:
						animated_sprite.play("PlayerPushSide")
					else:
						animated_sprite.play("PlayerWalkSide")
				2:
					if pushanim:
						animated_sprite.play("PlayerPushBack")
					else:
						animated_sprite.play("PlayerWalkBack")
				3:
					if pushanim:
						animated_sprite.play("PlayerPushSide")
					else:
						animated_sprite.play("PlayerWalkSide")
				_:
					print("Error: Direction isn't between 0 and 3")
			
## process pushing blocks
func collision_handler() -> bool:
	var pushing = false
	
	# https://forum.godotengine.org/t/need-an-easy-solution-to-top-down-block-pushing-being-buggy/104033
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			var collision_direction = -c.get_normal()
			var impulse_direction = Vector2.ZERO
			# Check whether collision is from the left/right or top/bottom
			if abs(collision_direction.x) > abs(collision_direction.y):
				# Collision direction is left/right
				if collision_direction.x < 0:
					impulse_direction = Vector2(-1, 0)
				else:
					impulse_direction = Vector2(1, 0)
			else:
				# Collision direction is up/down
				if collision_direction.y < 0:
					impulse_direction = Vector2(0,-1)
				else:
					impulse_direction = Vector2(0, 1)
			c.get_collider().apply_central_impulse(impulse_direction * push_force)
			
			pushing = true
	return pushing

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
			
	#if is_on_floor():
	#	can_jump = true
	#	coyote_timer = 0
	#	jumps = MAX_JUMPS
		
	# Add the gravity.
	#if not is_on_floor():
		# coyote time aka jumping when leaving ground
	#	coyote_timer += delta
		
	#	if coyote_timer > MAXCOYOTETIME:
			# can't jump if we're in the air for too long
	#		if can_jump:
				# remove the jump since we're in the air
	#			jumps = min(jumps, MAX_JUMPS-1)
	#		can_jump = false
#		if velocity.y < MAX_FALL_VELOCITY:
#			velocity += get_gravity() * delta * 0.5

	# Jump Handling
	# If light tap, we decrease our velocity
	#if Input.is_action_just_released("jump") and velocity.y < 0 and !waitforanimationend:
		# updates the velocity
#		velocity.y = JUMP_VELOCITY * 0.25
	#	pass
	
	# If held, or first tapped we give full height, also handles multiple jumps
	#if Input.is_action_just_pressed("jump") and (can_jump or (jumps > 0)) and !waitforanimationend :
	#	# removes 1 jump to number of jumps (jumps variable)
	#	jumps -= 1
	#	#print("jumps: ",jumps)
	#	
	#	# play the jump sfx
	#	play_sfx("Jump")
	#	
		# updates the velocity
#		velocity.y = JUMP_VELOCITY
		
	# Handles PickUp objects and enemies
	#if Input.is_action_just_pressed("pick") and pickupanim == false and !waitforanimationend and is_on_floor():
	#	# indicates that we use pickup variants of animations
	#	pickupanim = true
	#	
	#	# stop animations and stop player from moving
	#	waitforanimationend = true
	#	skipMoveProcess = true
	#	
	#	# Play the animation for picking up
	#	animated_sprite.play("PlayerPickupSide")
	#	# TODO: Add sfx for pickup
	#	
	#	# freezes the player in place for the duration of the animation
	#	velocity.x = 0
	#	
	#	# waits for a fixed amount for the animation to play
	#	await animated_sprite.animation_finished
	#	
	#	# tries to pickUp the item right below us
	#	if !pickUp():
	#		# if we did not pick anything up, or the object wasn't pickable (same shit really)
	#		# stop the animation
	#		pickupanim = false
	#		
	#		# makes the player shrug to waste his time
	#		animated_sprite.play("PlayerShrug")
	#		
	#		# wait for shrug animation end
	#		await animated_sprite.animation_finished
	#		
	#	# allows animation to play and player to move again
	#	waitforanimationend = false
	#	skipMoveProcess = false
	#	
	# Handles throwing objects and enemies
	#if Input.is_action_just_pressed("pick") and pickupanim == true and !waitforanimationend:
	#	# indicate that we aren't holding anything anymore and locks animations
	#	pickupanim = false
	#	waitforanimationend = true
	#	
	#	# Play the throw animation
	#	animated_sprite.play("PlayerThrow")
	#	
	#	# Throw the held object/enemy
	#	throw()
	#	
	#	# wait for throw to finish and then allows animation to play again
	#	await animated_sprite.animation_finished
	#	waitforanimationend = false
		
	# Handles attacking, right now only for sword and on side
	if Input.is_action_just_pressed("attack") and !waitforanimationend and !pickupanim:
		print("attack") # debug message
		
		var changed_dir = side_dir
		lock_direction = true
		
		# play the attack animation and locks animation for the length of the animation
		if dir == 0:
			print("down")
			if side_dir == -1:
				changed_dir = 1
				player_body.scale.x = -1
			animation_player.play("attackFront")
		elif dir == 2:
			print("up")
			if side_dir == -1:
				changed_dir = 1
				player_body.scale.x = -1
			animation_player.play("attackBack")
		else:
			print("other")
			animation_player.play("attackSide")
		
		waitforanimationend = true
		await animation_player.animation_finished
		waitforanimationend = false
		jumpanim = false
		
		if changed_dir != side_dir:
			if side_dir == 1:
				player_body.scale.x = -1
			elif side_dir == -1:
				player_body.scale.x = -1
		lock_direction = false
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Vector2(0,0)
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")
	
	print("direction: ", direction)
	direction = direction.normalized()
	print("direction normalized: ", direction)
	
	if abs(direction.x)+abs(direction.y) < deadzone:
		direction.x = 0
		direction.y = 0
	
	# check if running
	if Input.is_action_just_pressed("run"):
		#print("running!") # debug message
		
		# updates the speed multiplier with run speed
		speedMult = RUN_MULT
		
	elif Input.is_action_just_released("run"):
		# defaults back to 1 speed multiplier
		speedMult = 1.0
		velocity.x = min(WALK_CAP*direction.x, velocity.x) 
		
	# Flip sprite if changed direction.x
	if (direction.x < 0):
		# flip sprite if we changed direction.x
		if side_dir != -1 && !lock_direction:
			player_body.scale.x = -1
				
		# updates our direction.x
		dir = 3
		side_dir = -1
	elif (direction.x > 0):
		# flip sprite if we changed direction.x
		if side_dir != 1 && !lock_direction:
			player_body.scale.x = -1
				
		# updates our direction.x
		dir = 1
		side_dir = 1
	
	# Flip sprite if changed direction.y
	if (direction.y < 0):
		# updates our direction.y
		dir = 2
	elif (direction.y > 0):
		# updates our direction.y
		dir = 0
		
	# handles pushing blocks
	pushanim = collision_handler()
	
	# animation handling
	if !waitforanimationend:
		process_animation(direction.x, direction.y)
			
	if !skipMoveProcess:
		# Apply Movement
		if direction.x:
			if (velocity.x*direction.x < WALK_CAP * abs(direction.x) and speedMult == 1.0) or (velocity.x*direction.x < RUN_CAP * abs(direction.x) and speedMult != 1.0):
				velocity.x += direction.x * SPEED * speedMult
			if velocity.x > 0:
				velocity.x = min(velocity.x, SPEED_CAP * speedMult * abs(direction.x))
			else:
				velocity.x = max(velocity.x, -SPEED_CAP * speedMult * abs(direction.x))
			# if over the speed cap, slow down until under
			if abs(velocity.x) > RUN_CAP * abs(direction.x):
				velocity.x -= direction.x * 10
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		# movement for y axis
		if direction.y:
			if (velocity.y*direction.y < WALK_CAP * abs(direction.y) and speedMult == 1.0) or (velocity.y*direction.y < RUN_CAP * abs(direction.y) and speedMult != 1.0):
				velocity.y += direction.y * SPEED * speedMult
			if velocity.y > 0:
				velocity.y = min(velocity.y, SPEED_CAP * speedMult * abs(direction.y))
			else:
				velocity.y = max(velocity.y, -SPEED_CAP * speedMult * abs(direction.y))
			# if over the speed cap, slow down until under
			if abs(velocity.y) > RUN_CAP * abs(direction.y):
				velocity.y -= direction.y * 10
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
			
		if velocity.length() > 1:
			print("velocity.length: ", velocity.length())
			velocity.normalized()
			
	move_and_slide()
	
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, self.position)
