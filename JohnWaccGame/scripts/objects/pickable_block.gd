extends CharacterBody2D

var direction = -1
var dir = -1 # same thing has direction but stores only values -1 and 1
@export var MAX_FALL_VELOCITY = 300

@export var MAX_HEALTH = 1
var health = MAX_HEALTH
var invulnerable = false
@onready var damage_timer: Timer = $DamageTimer # invulnerability frames basically

var pickedUpBy
var startThrow = false
var dead = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var thrown_hurt_box: CollisionShape2D = $ThrowHurtBox/CollisionShape2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func set_dead():
	dead = true
	velocity = Vector2(0,0)

func pickedUp(player: CharacterBody2D) -> void:
	#print("car picked")
	pickedUpBy = player
	collision_shape.disabled = true
	if (player.has_method("get_direction")):
		direction = player.get_direction()
	
func thrown() -> void:
	#print("car thrown")
	startThrow = true
	move_and_slide()
	await get_tree().create_timer(0.1).timeout
	startThrow = false
	pickedUpBy = null
	collision_shape.disabled = false
	thrown_hurt_box.disabled = false
	await get_tree().create_timer(0.5).timeout
	velocity.x = move_toward(velocity.x, 0, 100)
	await get_tree().create_timer(2).timeout
	thrown_hurt_box.disabled = true
	
func take_damage(damage, direction) -> void:
	if !invulnerable:
		invulnerable = true
		velocity = 0*direction
		damage_timer.start()
		health -= damage
		if health <= 0:
			dead = true
			animation_player.play("death")

func _on_death_timer_timeout() -> void:
	invulnerable = false

func _physics_process(delta: float) -> void:
	# process gravity
	if startThrow:
		velocity.x += 18 * dir
		velocity.y -= 10
	elif pickedUpBy != null:
		var temp = Input.get_axis("left", "right")
		if temp != 0:
			direction = temp
			
		position = Vector2(pickedUpBy.position.x, pickedUpBy.position.y-23)
	elif not is_on_floor() and !dead:
		if (dead):
			print("bro what the frick")
		if velocity.y < MAX_FALL_VELOCITY:
			velocity += get_gravity() * delta * 0.5
	
	# sets dir for anything that only need
	if direction > 0:
		dir = 1
	elif direction < 0:
		dir = -1	

	if !startThrow:
		velocity.x = move_toward(velocity.x, 0, 5)
	
	move_and_slide()
	
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, self.position)
