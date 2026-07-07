extends CharacterBody2D

## Car - By Ledouzy
## Dictate the movement and functions that a car has.
## Walks left and right, turning at an obstacle.


@export_group("Movement")
@export var speed = 10
@export var MAX_FALL_VELOCITY = 300

@export_group("Stats")
@export var MAX_HEALTH = 2
@export var dead = false

var direction = -1
var dir = -1 # sames as direction but only -1 and 1 basically left or right

var invulnerable = false

# animation
var startThrow = false
var deathanim = false
var waitforanimationend = false

# Movement logic
var pickedUpBy
var skipMoveProcess = false
var walkDisabled = false

# Reference to objects needed
# taking damage
@onready var health = MAX_HEALTH
@onready var damage_timer: Timer = $DamageTimer # invulnerability frames basically

@onready var throw_timer: Timer = $ThrowTimer

# Checks for Walls
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

# Animation
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blink_animation_player: AnimationPlayer = $BlinkAnimationPlayer

# collision
@onready var hurtbox_collision: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var collision_shape_2: CollisionShape2D = $CharacterBody2D2/CollisionShape2D2
@onready var collision_shape_3: CollisionShape2D = $CollisionShape2D3
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
		
		# play sfx
		play_sfx("Car")
		
		# check if below 0
		if health <= 0:
			# death if below 0
			animation_player.play("death")

		else:
			# plays damage animation
			animated_sprite.play("TakeDamage")
			
			
			
			# stop movement and lock until animation end
			skipMoveProcess = true
			waitforanimationend = true
			# disable hurtbox of the enemy
			hurtbox_collision.disabled = true
			# make the enemy blink
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
			animated_sprite.play("Death")
			# mark that the animation has been played once
			deathanim = false
			# skip move and wait for the end of the animation
			skipMoveProcess = true
			waitforanimationend = true
			
	
	if startThrow:
		# apply force for the throw
		velocity.x += 1250 * delta * dir
		velocity.y -= 350 * delta
	elif pickedUpBy != null:
		# apply the same movement as the player and direction
		var temp = Input.get_axis("left", "right")
		
		# make sure that direction is not 0 since else we're stuck in place
		if temp != 0:
			direction = temp
			
		position = Vector2(pickedUpBy.position.x, pickedUpBy.position.y-16)
		
	elif not is_on_floor():
		# process gravity
		if velocity.y < MAX_FALL_VELOCITY:
			velocity += get_gravity() * delta * 0.5
	# if on floor
	else:
		# disable the hurtbox for the throw
		thrown_hurt_box.disabled = true
	
	# sets dir for anything that only need the sign
	if direction > 0:
		dir = 1
	elif direction < 0:
		dir = -1
	
	# movement logic
	if !waitforanimationend:
		# flip the sprite in the correct direction
		if (direction < 0):
			animated_sprite.flip_h = true
		elif (direction > 0):
			animated_sprite.flip_h = false
		
		# if not picked up
		if pickedUpBy == null:
			# check for walls on the right and change direction if yes
			if ray_cast_right.is_colliding():
				direction = 1
				animated_sprite.flip_h = true
				
			# same but on the left
			if ray_cast_left.is_colliding():
				direction = -1
				animated_sprite.flip_h = false
				
			# if between two walls
			if ray_cast_left.is_colliding() && ray_cast_right.is_colliding():
				# just wait
				animated_sprite.play("IdleFront")
			else:
				# play walk animation
				animated_sprite.play("WalkSide")
				
				# move the enemy if movement is not disabled
				if !walkDisabled:
					position.x += direction * delta * speed
		else:
			# if grabbed, play the animation
			animated_sprite.play("Grabbed")
	# if not thrown, apply friction to the car
	if !startThrow:
		velocity.x = move_toward(velocity.x, 0, speed/2*delta*35)
	
	# applies movement
	move_and_slide()
	
# play a sound by calling the audio manager
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, self.position)
