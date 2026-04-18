extends CharacterBody2D

@export var speed = 10
var direction = -1
@export var MAX_FALL_VELOCITY = 300

var pickedUpBy
var startThrow = false

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var killzone_collison: CollisionShape2D = $Killzone/CollisionShape2D
@onready var collision_shape_2: CollisionShape2D = $CollisionShape2D2
@onready var collision_shape_3: CollisionShape2D = $CollisionShape2D3


func pickedUp(player: CharacterBody2D) -> void:
	print("car picked")
	pickedUpBy = player
	killzone_collison.disabled = true
	animated_sprite.flip_v = true
	collision_shape_2.disabled = true
	collision_shape_3.disabled = true
	
func thrown() -> void:
	print("car thrown")
	startThrow = true
	move_and_slide()
	await get_tree().create_timer(0.1).timeout
	killzone_collison.disabled = false
	animated_sprite.flip_v = false
	collision_shape_2.disabled = false
	collision_shape_3.disabled = false
	pickedUpBy = null
	startThrow = false
	await get_tree().create_timer(0.5).timeout
	velocity.x = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (direction < 0):
		animated_sprite.flip_h = false
	elif (direction > 0):
		animated_sprite.flip_h = true
		
	if pickedUpBy == null:
		# check for walls and change direction if yes
		if ray_cast_right.is_colliding():
			direction = 1
			animated_sprite.flip_h = true
		if ray_cast_left.is_colliding():
			direction = -1
			animated_sprite.flip_h = false
		if ray_cast_left.is_colliding() && ray_cast_right.is_colliding():
			animated_sprite.play("CarFrontIdle")
			pass
		else:
			animated_sprite.play("CarSideWalk")
			position.x += direction * delta * speed
	else:
		animated_sprite.play("CarGrabbed")

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
