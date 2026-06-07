extends CharacterBody2D

@export var speed = 10
var direction = -1
var dir = -1 # same thing has direction but stores only values -1 and 1
@export var MAX_FALL_VELOCITY = 300

@export var MAX_HEALTH = 2
var health = MAX_HEALTH
var invulnerable = false
@onready var damage_timer: Timer = $DamageTimer # invulnerability frames basically

var pickedUpBy
var startThrow = false
var deathanim = false
var waitforanimationend = false
var skipMoveProcess = false
var walkDisabled = false

# Death Flags
@export var dead = false

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox_collison: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var collision_shape_2: CollisionShape2D = $CollisionShape2D2
@onready var collision_shape_3: CollisionShape2D = $CollisionShape2D3
@onready var thrown_hurt_box: CollisionShape2D = $ThrowHurtBox/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blink_animation_player: AnimationPlayer = $BlinkAnimationPlayer

func set_dead():
	dead = true
	deathanim = true
	play_sfx("Death")

# returns value of dead
func is_dead() -> bool:
	return dead

func pickedUp(player: CharacterBody2D) -> void:
	#print("car picked")
	pickedUpBy = player
	walkDisabled = true
	hurtbox_collison.disabled = true
	animated_sprite.flip_v = true
	collision_shape_2.disabled = true
	collision_shape_3.disabled = true
	if (player.has_method("get_direction")):
		direction = player.get_direction()
	
func thrown() -> void:
	#print("car thrown")
	startThrow = true
	move_and_slide()
	await get_tree().create_timer(0.1).timeout
	collision_shape_2.disabled = false
	collision_shape_3.disabled = false
	startThrow = false
	pickedUpBy = null
	thrown_hurt_box.disabled = false
	await get_tree().create_timer(0.5).timeout
	velocity.x = move_toward(velocity.x, 0, 100)
	await get_tree().create_timer(2).timeout
	if pickedUpBy == null:
		walkDisabled = false
		thrown_hurt_box.disabled = true
		hurtbox_collison.disabled = false
		animated_sprite.flip_v = false
	
func take_damage(damage, direction) -> void:
	if !invulnerable:
		invulnerable = true
		velocity.x = 100*-dir
		damage_timer.start()
		health -= damage
		if health <= 0:
			animation_player.play("death")
		else:
			animated_sprite.play("CarTakeDamage")
			skipMoveProcess = true
			waitforanimationend = true
			hurtbox_collison.disabled = true
			blink_animation_player.play("blink")
			await get_tree().create_timer(0.5).timeout
			skipMoveProcess = false
			waitforanimationend = false
			await get_tree().create_timer(.5).timeout
			hurtbox_collison.disabled = false

func _on_death_timer_timeout() -> void:
	invulnerable = false

func _physics_process(delta: float) -> void:
	if (dead):
		# first play the death animation once
		if (deathanim):
			animated_sprite.play("CarDeath")
			deathanim = false
			skipMoveProcess = true
			waitforanimationend = true
		#return # skip the entire physics calculation
	# process gravity
	if startThrow:
		velocity.x += 18 * dir
		velocity.y -= 10
	elif pickedUpBy != null:
		var temp = Input.get_axis("left", "right")
		if temp != 0:
			direction = temp
			
		position = Vector2(pickedUpBy.position.x, pickedUpBy.position.y-16)
	elif not is_on_floor():
		if velocity.y < MAX_FALL_VELOCITY:
			velocity += get_gravity() * delta * 0.5
	
	# sets dir for anything that only need
	if direction > 0:
		dir = 1
	elif direction < 0:
		dir = -1	
	
	if !waitforanimationend:
		if (direction < 0):
			animated_sprite.flip_h = false
		elif (direction > 0):
			animated_sprite.flip_h = true
			
		if pickedUpBy == null:
			# check for walls and change direction if yes
			if ray_cast_right.is_colliding():
				direction = 1
				animated_sprite.flip_h = false
			if ray_cast_left.is_colliding():
				direction = -1
				animated_sprite.flip_h = true
			if ray_cast_left.is_colliding() && ray_cast_right.is_colliding():
				animated_sprite.play("CarIdleFront")
				pass
			else:
				animated_sprite.play("CarWalkSide")
				if !walkDisabled:
					position.x += direction * delta * speed
		else:
			animated_sprite.play("CarGrabbed")
	if !startThrow:
		velocity.x = move_toward(velocity.x, 0, 5)
	
	move_and_slide()
	
func play_sfx(sfx_name):
	audio_manager.play_sfx(sfx_name, 0, self.position)
