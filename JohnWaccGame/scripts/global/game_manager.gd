extends Control

# number of coins, variable name is a little off since this is from a tutorial at the start of the project
var score = 0

# text for the UI
@onready var coins_label: Label = $CanvasLayer/Base/MarginContainer/HBoxContainer/CoinsLabel
@onready var health_label: Label = $CanvasLayer/Base/MarginContainer/HBoxContainer/HealthLabel

# reference to the player
@onready var player: CharacterBody2D = $"../Player".get_player()

# reference to the pause menu
@onready var pause_menu: Control = $CanvasLayer/pause_menu

func _ready() -> void:
	# get the number of coins from the save data
	score = save_system.current_data.coins
	# update coins and health
	coins_label.text = "Coins: " + str(score)
	health_label.text = "Health: " + str(player.get_health()) + "/" + str(player.get_max_health())

func _process(delta: float) -> void:
	# update health in process, technically could just have a function to do that like for coins
	health_label.text = "Health: " + str(player.get_health()) + "/" + str(player.get_max_health())
	
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
	coins_label.text = "Coins: " + str(score)
