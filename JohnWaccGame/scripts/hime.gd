extends CharacterBody2D

@export var speed = 10
var direction = -1
@export var MAX_FALL_VELOCITY = 300

var pickedUpBy
var startThrow = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func pickedUp(player: CharacterBody2D) -> void:
	print("Hime picked")
	pickedUpBy = player
	collision_shape.disabled = true
	animated_sprite.play("HimeGrabbed")
	
func thrown() -> void:
	print("Hime thrown")
	startThrow = true
	move_and_slide()
	await get_tree().create_timer(0.1).timeout
	collision_shape.disabled = false
	pickedUpBy = null
	startThrow = false
	await get_tree().create_timer(0.5).timeout
	animated_sprite.play("HimeFrontIdle")
	velocity.x = 0
	
func _process(delta: float) -> void:
	if (direction < 0):
		animated_sprite.flip_h = false
	elif (direction > 0):
		animated_sprite.flip_h = true

func _physics_process(delta: float) -> void:
	# process gravity
	if startThrow:
		velocity.x += 500 * delta * direction
		velocity.y -= 500 * delta
	elif pickedUpBy != null:
		var temp = Input.get_axis("left", "right")
		if temp != 0:
			direction = temp
			
		position = Vector2(pickedUpBy.position.x, pickedUpBy.position.y-16)
	elif not is_on_floor():
		if velocity.y < MAX_FALL_VELOCITY:
			velocity += get_gravity() * delta * 0.5
			
	move_and_slide()
