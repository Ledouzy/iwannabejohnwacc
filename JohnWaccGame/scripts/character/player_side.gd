extends CharacterBody2D
class_name player

# Movement Parameters
# Speed
@export var SPEED = 20 ## base speed value
@export var SPEED_CAP = 240
@export var WALK_CAP = 90
@export var RUN_CAP = 135
@export var RUN_MULT = 1.5 ## Sprint multiplier
var speedMult = 1.0 ## mults the speed by this constant, changes if sprinting
# Jump
@export var JUMP_VELOCITY = -200.0 ## How high you jump
@export var MAX_FALL_VELOCITY = 300 ## How fast you fall
@export var MAX_JUMPS = 1 ## number of jumps        
@onready var jumps = MAX_JUMPS # number of jumps left
@export var MAXCOYOTETIME = .14 # max time in air before we can't jump anymore
var coyote_timer = 0
var can_jump = true
var springjump = false
var skipisonfloor = false # bc godot is cringe

# deadzone
@export var deadzone = 0.25 ## min value before input is registered

# direction
var dir = 1 # direction of the player
var lock_direction = false

@export var MAX_HEALTH = 10 ## max hp
@onready var health = MAX_HEALTH # number of hits before dying
var invulnerable = false
@onready var damage_timer: Timer = $DamageTimer ## invulnerability frames basically
#var healthLock : Mutex # lock for not taking damage until invul frames end

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
#TODO: implement direction knockback
func take_damage(damage,direction) -> void:
	if !invulnerable:
		invulnerable = true
		player_body.collision_mask = 1
		
		damage_timer.start()
		health -= damage
		health = max(health,0)
		
		velocity.x = 60*direction
		
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
		player_body.collision_mask = 5
	
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
	jumps -= 1
	velocity += jump_height
	
	# cap the velocity so that we don't go too far up
	velocity.y = max(jump_height.y*1.25, velocity.y)
	
	#coyote_timer = MAXCOYOTETIME
	if jumps == 0:
		skipisonfloor = true
		springjump = true
		await get_tree().create_timer(0.01).timeout
		skipisonfloor = false
	
func _on_sword_down_body_entered(body: Node2D) -> void:
	if body != null:
		velocity.y = JUMP_VELOCITY

## Handles the playing of animations not specific to an action
func process_animation(direction) -> void:
	# grounded animation
	if is_on_floor():
		# we are not jumping and we can reset our number of jumps
		jumpanim = false
		
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
			
	if is_on_floor() and !skipisonfloor:
		can_jump = true
		springjump = false
		coyote_timer = 0
		jumps = MAX_JUMPS
		
	# Add the gravity.
	if not is_on_floor():
		# coyote time aka jumping when leaving ground
		coyote_timer += delta
		
		if coyote_timer > MAXCOYOTETIME:
			# can't jump if we're in the air for too long
			if can_jump:
				# remove the jump since we're in the air
				jumps = min(jumps, MAX_JUMPS-1)
			can_jump = false
		if velocity.y < MAX_FALL_VELOCITY:
			velocity += get_gravity() * delta * 0.5

	# Jump Handling
	# If light tap, we decrease our velocity
	if Input.is_action_just_released("jump") and velocity.y < 0 and !waitforanimationend and !springjump:
		# updates the velocity
		velocity.y = JUMP_VELOCITY * 0.25
	
	# If held, or first tapped we give full height, also handles multiple jumps
	if Input.is_action_just_pressed("jump") and (can_jump or (jumps > 0)) and !waitforanimationend :
		# removes 1 jump to number of jumps (jumps variable)
		jumps -= 1
		#print("jumps: ",jumps)
		
		# play the jump sfx
		play_sfx("Jump")
		
		# reset velocity if going down
		velocity.y = min(0, velocity.y)
		
		# updates the velocity
		velocity.y += JUMP_VELOCITY
		
		# cap the velocity so that we don't go too far up
		velocity.y = max(JUMP_VELOCITY*1, velocity.y)
		
	# Handles PickUp objects and enemies
	if Input.is_action_just_pressed("pick") and pickupanim == false and !waitforanimationend and is_on_floor():
		# indicates that we use pickup variants of animations
		pickupanim = true
		
		# stop animations and stop player from moving
		waitforanimationend = true
		skipMoveProcess = true
		
		# Play the animation for picking up
		animated_sprite.play("PlayerPickupFront")
		# TODO: Add sfx for pickup
		
		# freezes the player in place for the duration of the animation
		velocity.x = 0
		
		# waits for a fixed amount for the animation to play
		await animated_sprite.animation_finished
		
		# tries to pickUp the item right below us
		if !pickUp():
			# if we did not pick anything up, or the object wasn't pickable (same shit really)
			# stop the animation
			pickupanim = false
			
			# makes the player shrug to waste his time
			animated_sprite.play("PlayerShrug")
			
			# wait for shrug animation end
			await animated_sprite.animation_finished
			
		# allows animation to play and player to move again
		waitforanimationend = false
		skipMoveProcess = false
		
	# Handles throwing objects and enemies
	if Input.is_action_just_pressed("pick") and pickupanim == true and !waitforanimationend:
		# indicate that we aren't holding anything anymore and locks animations
		pickupanim = false
		waitforanimationend = true
		
		# Play the throw animation
		animated_sprite.play("PlayerThrowSide")
		await get_tree().create_timer(.1).timeout
		
		# Throw the held object/enemy
		throw()
		
		# wait for throw to finish and then allows animation to play again
		await animated_sprite.animation_finished
		waitforanimationend = false
		
	# Handles attacking, right now only for sword and on side
	# TODO: Handle attack in all direction if in air and 2 directions on the ground (up side down and up side respectively)
	if Input.is_action_just_pressed("attack") and !waitforanimationend and !pickupanim:
		# print("attack") # debug message
		
		var changed_dir = dir
		lock_direction = true
		
		# play the attack animation and locks animation for the length of the animation
		if Input.is_action_pressed("down"):
			# print("down")
			if dir <= -1:
				changed_dir = 1
				player_body.scale.x = -1
			animation_player.play("attackFront")
		elif Input.is_action_pressed("up"):
			# print("up")
			if dir <= -1:
				changed_dir = 1
				player_body.scale.x = -1
			animation_player.play("attackBack")
		else:
			# print("other")
			animation_player.play("attackSide")
			
		waitforanimationend = true
		await animation_player.animation_finished
		waitforanimationend = false
		jumpanim = false
		
		if changed_dir != dir:
			if dir == 1:
				player_body.scale.x = -1
			elif dir == -1:
				player_body.scale.x = -1
		lock_direction = false
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if abs(direction) < deadzone:
		direction = 0
	
	# check if running
	if Input.is_action_just_pressed("run"):
		#print("running!") # debug message
		
		# updates the speed multiplier with run speed
		speedMult = RUN_MULT
		
	elif Input.is_action_just_released("run"):
		# defaults back to 1 speed multiplier
		speedMult = 1.0
		# limits back to the walking speed cap the speed
		velocity.x = min(WALK_CAP*direction, velocity.x)
		
	# Flip sprite if changed direction
	if (direction < 0):
		# flip sprite if we changed direction
		if dir != -1 && !lock_direction:
			player_body.scale.x = -1
				
		# updates our direction
		dir = -1
	elif (direction > 0):
		# flip sprite if we changed direction
		if dir != 1 && !lock_direction:
			player_body.scale.x = -1
				
		# updates our direction
		dir = 1
	
	# animation handling
	if !waitforanimationend:
		process_animation(direction)
			
	if !skipMoveProcess:
		# Apply Movement
		if direction:
			if (velocity.x*direction < WALK_CAP * abs(direction) and speedMult == 1.0) or (velocity.x*direction < RUN_CAP * abs(direction) and speedMult != 1.0):
				velocity.x += direction * SPEED * speedMult
			if velocity.x > 0:
				velocity.x = min(velocity.x, SPEED_CAP * speedMult * abs(direction))
			else:
				velocity.x = max(velocity.x, -SPEED_CAP * speedMult * abs(direction))
			# if over the speed cap, slow down until under
			if abs(velocity.x) > RUN_CAP * abs(direction):
				velocity.x -= direction * 10
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	move_and_slide()
	
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, self.position)
	
