extends CharacterBody2D

## Car Topdown - By Ledouzy
## Dictate the movement and functions that topdown Car has.
## Walks left and right or up and down, turning at an obstacle.


@export_group("Movement")
@export var speed = 10
@export var MAX_FALL_VELOCITY = 300
@export var left_right = true # if false, up or down

@export_group("Stats")
@export var MAX_HEALTH = 2
@export var dead = false

var direction = -1
var dir = -1 # sames as direction but only -1 and 1 basically left or right

var invulnerable = false

# animation
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

# Checks for Walls
@onready var ray_cast_up: RayCast2D = $RayCastUp
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

# Animation
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blink_animation_player: AnimationPlayer = $BlinkAnimationPlayer

# collision
@onready var hurtbox_collision: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var collision_shape_3: CollisionShape2D = $CollisionShape2D3


# set dead to true
func set_dead():
	dead = true
	deathanim = true
	play_sfx("Death")


# returns value of dead
func is_dead() -> bool:
	return dead

	
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
	
	# sets dir for anything that only need the sign
	if direction > 0:
		dir = 1
	elif direction < 0:
		dir = 3
	
	# movement logic
	if !waitforanimationend:
		# left right movement
		if left_right:
			# flip the sprite in the correct direction
			if (direction < 0):
				animated_sprite.flip_h = true
			elif (direction > 0):
				animated_sprite.flip_h = false
			
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
			# check for walls on the right and change direction if yes
			if ray_cast_up.is_colliding():
				direction = 1
					
			# same but on the left
			if ray_cast_down.is_colliding():
				direction = -1
					
			# if between two walls
			if ray_cast_up.is_colliding() && ray_cast_down.is_colliding():
				# just wait
				animated_sprite.play("IdleFront")
			else:
				# play walk animation
				if direction > 0:
					animated_sprite.play("WalkFront")
				elif direction < 0:
					animated_sprite.play("WalkBack")
					
				# move the enemy if movement is not disabled
				if !walkDisabled:
					position.y += direction * delta * speed

	# apply friction to the car
	velocity.x = move_toward(velocity.x, 0, speed*delta)
	velocity.y = move_toward(velocity.x, 0, speed*delta)
	
	# applies movement
	move_and_slide()
	
# play a sound by calling the audio manager
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, self.position)
