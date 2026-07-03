extends Control


# number of coins, variable name is a little off since this is from a tutorial at the start of the project
var score = 0
var max_health = -1
var health = -1
var hearts: Array[TextureRect] = []
var stage_names: Array = ["1-1","1-2","1-3","1-4","2-1","2-2","2-3","2-4","3-1","3-2","3-3","3-4","4-1","4-2","4-3","4-4","5-1","5-2","6-1","6-2"] # and so on and so forth, yeah it's shit

# text for the UI
@onready var coins_label: Label = $CanvasLayer/Base/MarginContainer/HBoxContainer/CoinsLabel
@onready var health_label: Label = $CanvasLayer/Base/MarginContainer/HBoxContainer/HealthLabel
@onready var name_label: Label = $CanvasLayer/Base/MarginContainer/HBoxContainer/NameLabel
@onready var stage_label: Label = $CanvasLayer/Base/MarginContainer/HBoxContainer/StageLabel
@onready var heartsContainer: HBoxContainer = $CanvasLayer/Base/MarginContainer/HBoxContainer/Hearts
@onready var HEART = preload("uid://bfkt5jeh8r31c") # heart scene

# reference to the player
@onready var player: CharacterBody2D = $"../Player".get_player()

# reference to the pause menu
@onready var pause_menu: Control = $CanvasLayer/pause_menu


func _ready() -> void:
	# set up the number of hearts
	# only run this once
	if max_health == -1:
		for number_of_hearts in player.MAX_HEALTH/2:
			# instantiate a heart and add it to the list
			var heart = HEART.instantiate()
			
			heartsContainer.add_child(heart)
			
			# keep the heart stored in a list to keep access in order
			hearts.append(heart)
		
		# keep track of the health of the player
		max_health = player.MAX_HEALTH
		health = max_health
	
	# get the number of coins from the save data
	score = save_system.current_data.coins
	# update coins and health
	coins_label.text = str(score)
	health_label.text = str(player.get_health()) + "/" + str(player.get_max_health())
	name_label.text = save_system.current_data.name
	stage_label.text = stage_names.get(int(save_system.current_data.stage))


func _process(delta: float) -> void:
	# update health in process, technically could just have a function to do that like for coins
	health_label.text = str(player.get_health()) + "/" + str(player.get_max_health())
	
	# if our health decreased, update the hearts
	if player.get_health() < health:
		health = player.get_health()
		
		# if divisible by 2, change the half heart to a full heart
		if health % 2 == 0:
			# change every heart from the max until the current health to empty hearts
			for n in range(max_health/2-1, health/2-1, -1):
				hearts[n].texture.region = Rect2(16.0, 8.0, 8.0, 8.0)
		# if not divisible by 2, change the full heart to half a heart
		else:
			# change every heart from the max until the current health to empty hearts
			for n in range(max_health/2-1, health/2-1, -1):
				hearts[n].texture.region = Rect2(16.0, 8.0, 8.0, 8.0)
				
			# change the last heart to be a half heart
			hearts[health/2].texture.region = Rect2(24.0, 0.0, 8.0, 8.0)
	
	# if our health increased, update the hearts
	if player.get_health() > health:
		health = player.get_health()
		
		# if divisible by 2, change the half heart to a full heart
		if health % 2 == 0:
			# change every heart from the start until the current health to full hearts
			for n in range(0, health/2, 1):
				hearts[n].texture.region = Rect2(16.0, 0.0, 8.0, 8.0)
				
		# if not divisible by 2, change the full heart to half a heart
		else:
			# change every heart from the max until the current health to empty hearts
			for n in range(0, health/2-1, 1):
				hearts[n].texture.region = Rect2(16.0, 0.0, 8.0, 8.0)
			# change the last heart to be a half heart
			hearts[health/2].texture.region = Rect2(24.0, 0.0, 8.0, 8.0)
	
	# if pause is pressed, show the pause menu and pause the game
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		pause_menu.visible = true


# add n coin to the counter, defaults to 1
func add_point(n: int = 1):
	# update score and save that value
	score += n
	save_system.current_data.coins = score
	# display the new amount of coins
	coins_label.text = str(score)
