extends CharacterBody2D

@export var gravity_multiplier: float = 0.5

@export var SPEED = 2000.0
@export var JUMP_VELOCITY = -200.0
@export var starting_direction = -1
@export var jump_timer: Timer

var direction = 1
enum states {idle, patrol}
var current_state = states.idle
var lock_animation = false
var can_jump = true
var jump_timeout = false

@onready var animated_sprite: AnimatedSprite2D = $SkeletonBody/AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: CollisionShape2D = $SkeletonBody/HurtBox/CollisionShape2D
@onready var visibility_cast_right: ShapeCast2D = $SkeletonBody/VisibilityCastRight
@onready var visibility_cast_left: ShapeCast2D = $SkeletonBody/VisibilityCastLeft
@onready var jump_cast: ShapeCast2D = $SkeletonBody/JumpCast


func _ready() -> void:
	direction = starting_direction
	if direction < 0:
		animated_sprite.flip_h = true
		

func process_animation():
	if lock_animation:
		return
	if velocity.x != 0:
		animated_sprite.play("WalkSide")
	else:
		animated_sprite.play("IdleSide")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta
	else:
		if jump_timeout:
			can_jump = true
		lock_animation = false
		
	if visibility_cast_right.is_colliding():
		direction = 1
		jump_cast.target_position = Vector2(32,jump_cast.position.y)
		animated_sprite.flip_h = false
		current_state = states.patrol
	elif visibility_cast_left.is_colliding():
		direction = -1
		jump_cast.target_position = Vector2(-32,jump_cast.position.y)
		animated_sprite.flip_h = true
		current_state = states.patrol
	else:
		current_state = states.idle
		
	if jump_cast.is_colliding() and can_jump:
		jump_timeout = false
		jump_timer.start()
		animated_sprite.play("JumpSide")
		play_sfx("Jump")
		velocity.y = JUMP_VELOCITY
		can_jump = false
		lock_animation = true
	
	if current_state == states.patrol:
		velocity.x = direction * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	process_animation()
	
	move_and_slide()
	
# play a sound by calling the audio manager
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, self.position)
	


func _on_jump_timer_timeout() -> void:
	jump_timeout = true
