extends CharacterBody2D

@export_group("Movement")
@export var speed = 10
@export var MAX_FALL_VELOCITY = 300

var direction = -1
var dir = -1 # sames as direction but only -1 and 1 basically left or right

@export_group("Stats")
@export var MAX_HEALTH = 2

# taking damage
@onready var health = MAX_HEALTH
@onready var damage_timer: Timer = $DamageTimer # invulnerability frames basically
@export var dead = false

var invulnerable = false

# animation
var startThrow = false
var deathanim = false
var waitforanimationend = false
@onready var throw_timer: Timer = $ThrowTimer

# Movement logic
var pickedUpBy
var skipMoveProcess = false
var walkDisabled = false


# behaviour
@export_group("Behaviour")
@export var detection_range = 80 # base of 5 blocks for now

enum states {WAIT, CHARGE}
var current_state = states.WAIT

# Checks for Walls, Floor and Player
@onready var wall_check_right: RayCast2D = $WallCheckRight
@onready var wall_check_left: RayCast2D = $WallCheckLeft

@onready var floor_check_left: RayCast2D = $FloorCheckLeft
@onready var floor_check_right: RayCast2D = $FloorCheckRight

@onready var player_check_right: RayCast2D = $PlayerCheckRight
@onready var player_check_left: RayCast2D = $PlayerCheckLeft

# Reference to objects needed
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blink_animation_player: AnimationPlayer = $BlinkAnimationPlayer

@onready var collision_shape_2: CollisionShape2D = $CharacterBody2D/CollisionShape2D2
@onready var collision_shape_3: CollisionShape2D = $CollisionShape2D3

@onready var hurtbox_collision: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var thrown_hurt_box: CollisionShape2D = $ThrowHurtBox/CollisionShape2D

# set dead to true
func set_dead():
	dead = true
	deathanim = true
	play_sfx("Death")

# returns value of dead
func is_dead() -> bool:
	return dead

# logic for the object getting picked up
func pickedUp(player: CharacterBody2D) -> void:
	# marks that the object has been picked up, we store that object so that we know we are picked up and have it's position at all times
	pickedUpBy = player
	# disable movement
	walkDisabled = true
	
	# stop the timer for getting up
	throw_timer.stop()
	
	# disable collision and hurtbox
	hurtbox_collision.disabled = true
	collision_shape_2.disabled = true
	collision_shape_3.disabled = true
	
	# flip the sprite vertically
	animated_sprite.flip_v = true
	
	# turn towards the same direction as the player
	if (player.has_method("get_direction")):
		direction = player.get_direction()
	
# logic for the object being thrown
func thrown() -> void:
	# indicate that we are starting the throw for the physics process
	startThrow = true
	# initiate movement
	#move_and_slide()
	
	# wait until throw is finished
	await get_tree().create_timer(0.1).timeout
	# re-enable collisions
	collision_shape_2.disabled = false
	collision_shape_3.disabled = false
	# we are not at the start of the throw anymore
	startThrow = false
	# no longer picked up by the player
	pickedUpBy = null
	
	# enable the hurtbox for throwing
	thrown_hurt_box.disabled = false
	
	# wait a while, stop the object and wait again
	await get_tree().create_timer(0.5).timeout
	velocity.x = move_toward(velocity.x, 0, 100)
	throw_timer.start()
	await get_tree().create_timer(2).timeout
	
	# disable the hurtbox for the throw
	thrown_hurt_box.disabled = true
		
func _on_throw_timer_timeout() -> void:
	# if we haven't been picked up again
	if pickedUpBy == null:
		# re-enable walking and the hurtbox for the object and flip back up
		walkDisabled = false
		hurtbox_collision.disabled = false
		animated_sprite.flip_v = false

# logic for taking damage
func take_damage(damage, direction) -> void:
	# check if we are still in invulnerability frames
	if !invulnerable:
		# set invulnerable
		invulnerable = true
		# start invulnerability timer
		damage_timer.start()
		# apply knockback
		velocity = 100*direction
		# deal damage
		health -= damage
		
		# check if below 0
		if health <= 0:
			# death if below 0
			animation_player.play("death")
		else:
			# plays damage animation
			animated_sprite.play("BeaverTakeDamage")
			# stop movement and lock until animation end
			skipMoveProcess = true
			waitforanimationend = true
			# disable hurtbox of the enemy
			hurtbox_collision.disabled = true
			# make the enemy blink
			blink_animation_player.stop()
			blink_animation_player.play("blink")
			# wait until blinking ends
			await get_tree().create_timer(0.5).timeout
			# resume normal movement
			skipMoveProcess = false
			waitforanimationend = false
			await get_tree().create_timer(0.5).timeout
			# reactivate hurtbox
			hurtbox_collision.disabled = false

# when damage timer timeouts, removes invulnerability
func _on_damage_timer_timeout() -> void:
	invulnerable = false
	
## Handles jumping on springs
func spring_jump(jump_height):
	# changes direction in case we need to
	if jump_height.x < 0:
		direction = -1
	else:
		direction = 1
	# updates the velocity
	velocity = Vector2(jump_height.x * 0.6, jump_height.y)

func _physics_process(delta: float) -> void:
	# play when the object dies
	if (dead):
		# play the death animation once
		if (deathanim):
			# play the animation
			animated_sprite.play("BeaverDeath")
			# mark that the animation has been played once
			deathanim = false
			# skip move and wait for the end of the animation
			skipMoveProcess = true
			waitforanimationend = true

	if startThrow:
		# apply force for the throw
		velocity.x += 18 * dir
		velocity.y -= 10
	elif pickedUpBy != null:
		# apply the same movement as the player and direction
		var temp = Input.get_axis("left", "right")
		
		# make sure that direction is not 0 since else we're stuck in place
		if temp != 0:
			direction = temp
			
		position = Vector2(pickedUpBy.position.x, pickedUpBy.position.y-20)
		
	elif not is_on_floor():
		# process gravity
		if velocity.y < MAX_FALL_VELOCITY:
			velocity += get_gravity() * delta * 0.5
	
	# sets dir for anything that only need the sign
	if direction > 0:
		dir = 1
	elif direction < 0:
		dir = -1
	
	# WAIT LOGIC
	if !waitforanimationend and current_state == states.WAIT:
		# if player is on the right
		if player_check_right.is_colliding():
			# changes direction towards the right
			direction = -1
			dir = -1
			
			# unflip the sprite if it is flipped
			animated_sprite.flip_h = false
			
			# change state to charge
			current_state = states.CHARGE
			
		# if player is on the left
		if player_check_left.is_colliding():
			# changes direction towards the left
			direction = 1
			dir = 1
			
			# flip the sprite if it is not flipped
			animated_sprite.flip_h = true
			
			# change state to charge
			current_state = states.CHARGE
		# play the front idle animation
		animated_sprite.play("BeaverIdleFront")
	
	# CHARGE LOGIC
	if !waitforanimationend and current_state == states.CHARGE:
		# check direction of the charge and flip the sprite in the correct direction
		if (direction < 0):
			animated_sprite.flip_h = true
		elif (direction > 0):
			animated_sprite.flip_h = false
			
		# if not picked up
		if pickedUpBy == null:
			# if on a ledge, stop and switch back to wait
			if direction == 1 and !floor_check_right.is_colliding() or direction == -1 and !floor_check_left.is_colliding():
				current_state = states.WAIT
			else:
				# check for walls and change direction if yes (for the right)
				if wall_check_right.is_colliding():
					direction = 1
					animated_sprite.flip_h = true
					current_state = states.WAIT
				# same but on the left
				if wall_check_left.is_colliding():
					direction = -1
					animated_sprite.flip_h = false
					current_state = states.WAIT
				
				# if surrounded by walls, switch back to waiting state
				if wall_check_left.is_colliding() && wall_check_right.is_colliding():
					#animated_sprite.play("BeaverIdleFront")
					current_state = states.WAIT
					
				else:
					# play the walk animation
					animated_sprite.play("BeaverWalkSide")
					# move the enemy if movement is not disabled
					if !walkDisabled:
						position.x += direction * delta * speed
		else:
			# if grabbed, play the grabbed animation
			animated_sprite.play("BeaverGrabbed")
	# if a throw hasn't been started, apply friction
	if !startThrow:
		velocity.x = move_toward(velocity.x, 0, 5)
	
	# apply movement
	move_and_slide()
	
# play a sound by calling the audio manager
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, self.position)
