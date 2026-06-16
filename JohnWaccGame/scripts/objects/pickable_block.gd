extends CharacterBody2D

@export var MAX_FALL_VELOCITY = 300
@export_group("Stats")
@export var MAX_HEALTH = 1

# taking damage
var health = MAX_HEALTH
var dead = false
var invulnerable = false

# direction
var direction = -1
var dir = -1 # same thing has direction but stores only values -1 and 1

# Movement Logic
var startThrow = false
var pickedUpBy

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var thrown_hurt_box: CollisionShape2D = $ThrowHurtBox/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_timer: Timer = $DamageTimer # invulnerability frames basically


# set dead to true
func set_dead():
	dead = true
	velocity = Vector2(0,0)


# logic for the object getting picked up
func pickedUp(player: CharacterBody2D) -> void:
	# marks that the object has been picked up, we store that object so that we know we are picked up and have it's position at all times
	pickedUpBy = player
	
	# disable collision
	collision_shape.disabled = true
	
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
	# re-enable collision
	collision_shape.disabled = false
	
	# we are not at the start of the throw anymore
	startThrow = false
	# no longer picked up by the player
	pickedUpBy = null
	
	# enable the hurtbox for throwing
	thrown_hurt_box.disabled = false
	
	# wait a while, stop the object and wait again
	await get_tree().create_timer(0.5).timeout
	velocity.x = move_toward(velocity.x, 0, 100)


# logic for taking damage
func take_damage(damage, direction) -> void:
	# check if we are still in invulnerability frames
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
			
		position = Vector2(pickedUpBy.position.x, pickedUpBy.position.y-23)
		
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
	
	# if we are not at the start of a throw, apply friction
	if !startThrow:
		velocity.x = move_toward(velocity.x, 0, 5)
	
	# applies movement
	move_and_slide()


# play a sound by calling the audio manager
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, self.position)
