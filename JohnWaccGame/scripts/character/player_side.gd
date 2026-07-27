extends CharacterBody2D
class_name player

# Movement Parameters
# Speed
@export_group("Movement")
@export var SPEED = 1000 ## base speed value
@export var SPEED_CAP = 240
@export var WALK_CAP = 110
@export var RUN_CAP = 145
@export var RUN_MULT = 1.5 ## Sprint multiplier
@export var HOOKSHOT_SPEED = 300
# deadzone
@export var deadzone = 0.25 ## min value before input is registered
# Stats
@export_group("HP")
@export var MAX_HEALTH = 6 ## max hp
@export var dead = false # indicates that the player is dead
# Jump
@export_group("Jumping")
@export var JUMP_VELOCITY = -200.0 ## How high you jump
@export var MAX_FALL_VELOCITY = 300 ## How fast you fall
@export var MAX_JUMPS = 1 ## number of jumps        

@export var MAXCOYOTETIME = .14 # max time in air before we can't jump anymore

var speedMult = 1.0 ## mults the speed by this constant, changes if sprinting
var coyote_timer = 0
var can_jump = true
var springjump = false
var skipisonfloor = false # bc godot is cringe
var skipGravity = false

# direction
var dir = 1 # direction of the player
var lock_direction = false

var invulnerable = false

# pickup/throw objects
var pickedUp # stores the object that you picked up

# cause hookshot is buggy just like my code and i need to stop attack while hookshot
var attackanim

# indicates that we are using the hookshot
var hookshot_active = false
# staying at the point yout hooked to
var hookshot_cling = false
# target of the hookshot
var hookshot_target = null

# animation flags
var jumpanim = false # play the animation once
var deathanim = false # play the animation once
var pickupanim = false # will change to pickup variants of animations
var shruganim = false # stops idle animation, but can be cancelled
var waitforanimationend = false # stop other animations from playing until finished with current
var skipMoveProcess = false # stop the calculations for user input movement, letting only gravity affect player
var cant_jump = false # stops from jumping

# Initialized variables
@onready var jumps = MAX_JUMPS # number of jumps left
@onready var health = MAX_HEALTH # number of hits before dying
# Component references
@onready var damage_timer: Timer = $DamageTimer ## invulnerability frames basically
@onready var player_body: CharacterBody2D = $"."
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var throw_rayCast: RayCast2D = $RayCastThrow
@onready var death_timer: Timer = $DeathTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blink_animation_player: AnimationPlayer = $BlinkAnimationPlayer
@onready var camera: Camera2D = $"../../Camera2D"
@onready var hookshot_raycast: RayCast2D = $HookshotRaycast


# ready just for camera lmao. Else the camera will scroll while loading checkpoint
func _ready() -> void:
	# disable camera smoothing and set the camera to the player's location
	camera.position_smoothing_enabled = false
	camera.position = self.position
	
	# make sure one frame occurs with the position not smoothed
	await get_tree().create_timer(0.1).timeout
	
	# re-enable camera smoothing
	camera.position_smoothing_enabled = true
	
	# check if sprint is being held
	if Input.is_action_pressed("run"):
		# updates the speed multiplier with run speed
		speedMult = RUN_MULT


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
func take_damage(damage,direction) -> void:
	# check if we are still in invulnerability frames
	if !invulnerable:
		# set invulnerable
		invulnerable = true
		
		# make us not collide with enemies 
		player_body.collision_mask = 1
		
		# start invulnerability timer
		damage_timer.start()
		# apply knockback
		velocity += 60*direction
		
		# deal damage
		health -= damage
		health = max(health,0)
		
		# check if below 0
		if health <= 0:
			# death if below 0
			animation_player.play("death")
			
		else:
			# plays damage animation
			animated_sprite.play("TakeDamage")
			play_sfx("Damage")
			
			# stop movement and lock until animation end
			skipMoveProcess = true
			waitforanimationend = true
			await animated_sprite.animation_finished
			# resume normal movement
			skipMoveProcess = false
			waitforanimationend = false
			
			# make the player blink
			blink_animation_player.play("blink")
			
			# wait until blinking ends
			await blink_animation_player.animation_finished
			
		# set mask back to collide with enemies
		player_body.collision_mask = 5


# increase the health of the player by the amount specified
func heal_damage(heal_amount) -> void:
	play_sfx("Heal")
	
	health = min(health+heal_amount, MAX_HEALTH)
	

# set the player's health to max
func set_health_to_max():
	# only play sfx when not full health
	if health != MAX_HEALTH:
		play_sfx("Heal")
		
	health = MAX_HEALTH


# when damage timer timeouts, removes invulnerability
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
	
	# check if we picked up something
	if object == null:
		# we didn't, return false
		return false
		
	# if it doesn't have method picked up, check it's parent
	if !object.has_method("pickedUp"):
		object = object.get_parent()
	# if it has the method, call it
	if object.has_method("pickedUp"):
		# call the pickedUp method on the object
		object.call("pickedUp", self)
		
		# play sfx for pickup
		play_sfx("Pickup")
		
		# set the pickedUp field to the object we picked up
		pickedUp = object
		return true
		
	return false

## Handles throwing objects and enemies
func throw() -> void:
	# check first if we do have an item that we picked up, and check if that method does have a thrown method
	# TODO: change so it checks for class throwable when that class is added
	if pickedUp == null:
		# if we don't have something picked up, just return
		return
	if pickedUp.has_method("thrown"):
		play_sfx("Throw")
		# call the thrown method on the object
		pickedUp.call("thrown")


## Handles jumping on springs
func spring_jump(jump_height):
	# updates the velocity
	jumps -= 1
	velocity += jump_height
	
	# cap the velocity so that we don't go too far up
	velocity.y = max(jump_height.y*1.25, velocity.y)
	
	# if we don't have any jumps left
	if jumps == 0:
		# don't check if we're on the floor since we're on a spring
		skipisonfloor = true
		# we are doing a spring jump so skip things that don't need to be used
		springjump = true
		await get_tree().create_timer(0.01).timeout
		# reactive the check for on the floor after .01 seconds to not fuck things up
		skipisonfloor = false


func _on_sword_down_body_entered(body: Node2D) -> void:
	# disabled for now as it's a bit wack
	pass
	#if body != null:
	#	velocity.y = JUMP_VELOCITY
	

## Handles logic for hookshot
func hookshot(target):
	pass


## Handles the playing of animations not specific to an action
func process_animation(direction) -> void:
	# cling animation
	if hookshot_cling:
		animated_sprite.play("ClingSide")
	# grounded animation
	elif is_on_floor():
		# we are not jumping and we can reset our number of jumps
		jumpanim = false
		
		# if we are not moving, play the idle animation
		if direction == 0:
			# if we are holding an object/enemy, play the variant
			if (pickupanim):
				animated_sprite.play("PickupIdleSide")
			elif !shruganim and !hookshot_cling and !hookshot_active:
				animated_sprite.play("IdleSide")
		# else, we are moving, play the walk animation
		else:
			# if we are holding an object/enemy, play the variant
			if (pickupanim):
				animated_sprite.play("PickupWalkSide")
			else:
				animated_sprite.play("WalkSide")
	# we are in the air
	else:
		if !jumpanim:
			# play the jump animation, but only once
			jumpanim = true
			
			# if we are holding an object/enemy, play the variant
			if (pickupanim):
				animated_sprite.play("PickupJumpSide")
			else:
				# normal jump then
				animated_sprite.play("JumpSide")
				


## call at fixed interval for physics calculations
func _physics_process(delta: float) -> void:
	# ensures that the direction facing is correct
	if !lock_direction:
		if Input.is_action_pressed("right") and Input.is_action_pressed("left"):
			pass
		elif (velocity.x > 0 or Input.is_action_pressed("right")) and rotation < 0:
			scale.x = -1
		elif (velocity.x < 0 or Input.is_action_pressed("left")) and rotation > 0:
			scale.x = -1
	
	# When dead
	if (dead):
		# play the death animation once
		if (deathanim):
			animated_sprite.play("Death")
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
	if not is_on_floor() and not skipGravity:
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
	if Input.is_action_just_released("jump") and velocity.y < 0 and !springjump:
		# updates the velocity
		velocity.y = JUMP_VELOCITY * 0.25
	
	# If held, or first tapped we give full height, also handles multiple jumps
	if Input.is_action_just_pressed("jump") and ((can_jump or (jumps > 0)) and !cant_jump or hookshot_cling):
		#already jumped, remove that shit
		can_jump = false
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
		
		# if we jump after we clinged to a wall
		if hookshot_cling:
			# disable the flags for that
			skipMoveProcess = false
			waitforanimationend = false
			skipGravity = false
			hookshot_cling = false
			
			# Change to the jumping sprite
			animated_sprite.play("JumpSide")
			
			# Reset to hide the hookshot
			animation_player.play("hookReset")
		
	# Handles PickUp objects and enemies
	if Input.is_action_just_pressed("pick") and pickupanim == false and !waitforanimationend and is_on_floor():
		# indicates that we use pickup variants of animations
		pickupanim = true
		# prevent from jumping during animation
		cant_jump = true
		
		# stop animations and stop player from moving
		waitforanimationend = true
		skipMoveProcess = true
		
		# Play the animation for picking up
		animated_sprite.play("PickupFront")
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
			shruganim = true
			cant_jump = false
			
			# allows animation to play and player to move again
			waitforanimationend = false
			skipMoveProcess = false
			
			# makes the player shrug to waste his time
			animated_sprite.play("Shrug")
			
			# wait for shrug animation end
			await animated_sprite.animation_finished
			
			shruganim = false
			
		# allows animation to play and player to move again
		waitforanimationend = false
		skipMoveProcess = false
		cant_jump = false
		
	# Handles throwing objects and enemies
	if Input.is_action_just_pressed("pick") and pickupanim == true and !waitforanimationend:
		# indicate that we aren't holding anything anymore and locks animations
		pickupanim = false
		waitforanimationend = true
		
		# Play the throw animation
		animated_sprite.play("ThrowSide")
		await get_tree().create_timer(.1).timeout
		
		# Throw the held object/enemy
		throw()
		
		# wait for throw to finish and then allows animation to play again
		await animated_sprite.animation_finished
		waitforanimationend = false
		
	# Handles attacking, right now only for sword and on side
	if Input.is_action_just_pressed("attack") and !waitforanimationend and !pickupanim and !hookshot_active and !hookshot_target:
		# print("attack") # debug message
		# we are attacking
		attackanim = true
		
		# check for if we changed direction while we are attacking
		var changed_dir = dir
		# lock our direction
		lock_direction = true
		
		# play the attack animation and locks animation for the length of the animation
		if Input.is_action_pressed("down"):
			# print("down")
			# change the direction so the animation plays properly
			changed_dir = dir*-1
			player_body.scale.x = -1
			# plays the front attack animation
			animation_player.play("attackFront")
			
		elif Input.is_action_pressed("up"):
			# print("up")
			# change the direction so the animation plays properly
			#if dir <= -1:
				#changed_dir = 1
				#player_body.scale.x = -1
			# plays the back attack animation
			animation_player.play("attackBack")
		else:
			# print("other")
			# plays the side attack animation
			animation_player.play("attackSide")
		
		# wait for the end of animations before renabling jump animations or other shit
		waitforanimationend = true
		await animation_player.animation_finished
		waitforanimationend = false
		jumpanim = false
		
		# change back our direction to what it's supposed to be
		if changed_dir != dir:
			if dir == 1 or dir == -1:
				player_body.scale.x = -1
		# unlock our direction
		lock_direction = false
		
		# we are done
		attackanim = false
		
	# logic for activating hookshot
	if Input.is_action_just_pressed("hookshot") and ((!waitforanimationend and !pickupanim) or hookshot_cling) and !hookshot_active and !hookshot_target and !attackanim:
		
		# disable flags set by wall cling
		#hookshot_cling = false
		
		# play the hookshot animation, locking other animations during the this time
		lock_direction = true
		waitforanimationend = true
		animation_player.play("hookshotSide")
		
		#print("hookshot!")
		
		# indicate that we are hookshotting
		hookshot_active = true
		
		#wait for the end of the hookshot animation, then play the return animation
		await animation_player.animation_finished
		
		animation_player.play("hookReturnSide")
		
		await animation_player.animation_finished
		
		# if we are not clinging, hide the hookshot
		if !hookshot_cling and !hookshot_target:
			# Reset to hide the hookshot
			animation_player.play("hookReset")
			
			# unlock animation when done
			waitforanimationend = false
		
		hookshot_raycast.enabled = false
		hookshot_raycast.target_position = Vector2(0,0)
		
		hookshot_target = null
		hookshot_active = false
		lock_direction = false
	
	# while the hookshot is active
	if hookshot_active:
		var target = hookshot_raycast.get_collider()
		print("target: ", target)
		
		if target != null:
			# only happens once
			hookshot_active = false
			hookshot_target = target
			
			print("position: ", position)
			print("target position: ", target.position)
			
			
			skipMoveProcess = true
			skipGravity = true
			#velocity.y = 0
			
			# test to see if it works
			var hookshot_direction = target.position - position
			print("hookshot_direction: ", hookshot_direction)
			velocity = HOOKSHOT_SPEED * delta * (hookshot_direction + Vector2(0,4))
			print("velocity: ", velocity)
			
			# to avoid stale references
			target = null
			
			await SignalBus.stop_hookshot
			
			# stick to the hooked point
			hookshot_cling = true
			hookshot_target = null
			velocity = Vector2(0,0)
			
			# INSTEAD USE A SIGNAL FROM THE GRAPPLE POINT, WHEN PLAYER ON THE WALL, STOP AND GIVE BACK CONTROL
		
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	# apply deadzone to movement direction
	if abs(direction) < deadzone:
		direction = 0
	
	# check if running
	if Input.is_action_just_pressed("run"):
		#print("running!") # debug message
		
		# updates the speed multiplier with run speed
		speedMult = RUN_MULT
		
	elif Input.is_action_just_released("run"):
		# defaults back to 1 speed multiplier
		velocity = velocity/speedMult
		speedMult = 1.0
		
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
		# if moving
		if direction:
			# if if we are moving or if we are below the walk cap and walking or below the run cap and running
			if (velocity.x * direction < 0) or (abs(velocity.x) < WALK_CAP * abs(direction)
			and speedMult == 1.0) or (abs(velocity.x) < RUN_CAP * abs(direction) and speedMult != 1.0):
				# add velocity each frame
				velocity.x += direction * SPEED * speedMult * delta
			
			# if velocity greater than 0, cap it to the speed cap
			if velocity.x > 0:
				velocity.x = min(velocity.x, SPEED_CAP * speedMult * abs(direction))
				
			# if we are below 0, cap it to the speed cap in the other direction
			else:
				velocity.x = max(velocity.x, -SPEED_CAP * speedMult * abs(direction))
				
			# if over the speed cap, slow down until under
			if abs(velocity.x) > RUN_CAP * abs(direction):
				velocity.x -= direction * 10 * delta * 100
		# if not moving
		else:
			# apply friction
			velocity.x = move_toward(velocity.x, 0, SPEED*delta)
	
	# apply movement	
	move_and_slide()


# play a sound by calling the audio manager
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, self.position)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hookReturnSide":
		waitforanimationend = false
		hookshot_active = false
