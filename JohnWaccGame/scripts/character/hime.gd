extends CharacterBody2D

@export var speed = 10
var direction = -1
@export var MAX_FALL_VELOCITY = 300
@export var SPEED_CAP = 240
@export var RUN_CAP = 135

var pickedUpBy
var startThrow = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func pickedUp(player: CharacterBody2D) -> void:
	#print("Hime picked")
	pickedUpBy = player
	collision_shape.disabled = true
	velocity.y = 0
	velocity.x = 0
	
	if (player.has_method("get_direction")):
		direction = player.get_direction()
	animated_sprite.play("HimeGrabbed")
	
func thrown() -> void:
	#print("Hime thrown")
	startThrow = true
	move_and_slide()
	await get_tree().create_timer(0.1).timeout
	collision_shape.disabled = false
	pickedUpBy = null
	startThrow = false
	await get_tree().create_timer(0.5).timeout
	animated_sprite.play("HimeIdleFront")
	velocity.x = move_toward(velocity.x, 0, 100)
	
## Handles jumping on springs
func spring_jump(jump_height):
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
		
	# process gravity
	if startThrow:
		velocity.x += 18 * direction
		velocity.y -= 10
	elif pickedUpBy != null:
		var temp = Input.get_axis("left", "right")
		if temp != 0:
			direction = temp
			
		position = Vector2(pickedUpBy.position.x, pickedUpBy.position.y-16)
	elif not is_on_floor():
		if velocity.y < MAX_FALL_VELOCITY:
			velocity += get_gravity() * delta * 0.5
	#if velocity.x > 0:
	#	velocity.x = min(velocity.x, SPEED_CAP)
	#else:
	#	velocity.x = max(velocity.x, -SPEED_CAP)
	# if over the speed cap, slow down until under
	#if abs(velocity.x) > RUN_CAP:
	#	velocity.x -= direction * 10
	if !startThrow:
		velocity.x = move_toward(velocity.x, 0, 5)
			
	move_and_slide()
