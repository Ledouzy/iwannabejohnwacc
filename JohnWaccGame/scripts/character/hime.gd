extends CharacterBody2D

@export_group("Movement")
@export var speed = 10
@export var MAX_FALL_VELOCITY = 300

var direction = -1
var dir = -1 # sames as direction but only -1 and 1 basically left or right

# animation
var startThrow = false
var waitforanimationend = false

# Movement logic
var pickedUpBy
var skipMoveProcess = false

# Reference to objects needed

# Animation
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var throw_timer: Timer = $ThrowTimer

# collision
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


# logic for the object getting picked up
func pickedUp(player: CharacterBody2D) -> void:
	# marks that the object has been picked up, we store that object so that we know we are picked up and have it's position at all times
	pickedUpBy = player
	
	# disable collision and hurtbox
	collision_shape.disabled = true
	
	# turn towards the same direction as the player
	if (player.has_method("get_direction")):
		direction = player.get_direction()
	
# logic for the object being thrown
func thrown() -> void:
	# indicate that we are starting the throw for the physics process
	startThrow = true
	# initiate movement (basically direction fix)
	#move_and_slide()
	
	# wait until throw is finished
	await get_tree().create_timer(0.1).timeout
	# re-enable collisions
	collision_shape.disabled = false
	# we are not at the start of the throw anymore
	startThrow = false
	# no longer picked up by the player
	pickedUpBy = null
	
	# wait a while, stop the object and wait again
	await get_tree().create_timer(0.5).timeout
	# play recovery animation for hime
	animated_sprite.play("HimeDown")
	velocity.x = move_toward(velocity.x, 0, 100)
	throw_timer.start()
	await get_tree().create_timer(2).timeout

func _on_throw_timer_timeout() -> void:
	animated_sprite.play("HimeIdleFront")
	pass # Replace with function body.

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
	
	if (direction < 0):
		animated_sprite.flip_h = false
	elif (direction > 0):
		animated_sprite.flip_h = true
	
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
			
		position = Vector2(pickedUpBy.position.x, pickedUpBy.position.y-16)
		
	elif not is_on_floor():
		# process gravity
		if velocity.y < MAX_FALL_VELOCITY:
			velocity += get_gravity() * delta * 0.5
	
	# sets dir for anything that only need the sign
	if direction > 0:
		dir = 1
	elif direction < 0:
		dir = -1
	
	# movement logic
	if !waitforanimationend:
		# flip the sprite in the correct direction
		if (direction < 0):
			animated_sprite.flip_h = false
		elif (direction > 0):
			animated_sprite.flip_h = true
		
		# if not picked up
		if pickedUpBy == null:
			pass
			
		else:
			# if grabbed, play the animation
			animated_sprite.play("HimeGrabbed")
	# if not thrown, apply friction to the princess
	if !startThrow:
		velocity.x = move_toward(velocity.x, 0, 5)
	
	# applies movement
	move_and_slide()
	
# play a sound by calling the audio manager
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, self.position)
