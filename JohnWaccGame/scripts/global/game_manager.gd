extends Control

var score = 0
@onready var coins_label: Label = $CanvasLayer/Base/MarginContainer/HBoxContainer/CoinsLabel
@onready var health_label: Label = $CanvasLayer/Base/MarginContainer/HBoxContainer/HealthLabel
@onready var player: CharacterBody2D = $"../Player".get_player()
@onready var pause_menu: Control = $CanvasLayer/pause_menu

@onready var dialogue_box: Control = $CanvasLayer/DialogueBox
var text_box_open

func _ready() -> void:
	score = save_system.current_data.coins
	coins_label.text = "Coins: " + str(score)
	health_label.text = "Health: " + str(player.get_health()) + "/" + str(player.get_max_health())

func _process(delta: float) -> void:
	#coins_label.text = "Coins: " + str(score)
	health_label.text = "Health: " + str(player.get_health()) + "/" + str(player.get_max_health())
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		pause_menu.visible = true
	
	# debug
	if Input.is_action_just_pressed("debug"):
		if text_box_open:
			dialogue_box.toggle_off_dialogue_box()
			text_box_open = false
		else:
			text_box_open = true
			dialogue_box.toggle_on_dialogue_box()
			dialogue_box.display_text("This needs proper formatting\n so it might look weird")
		

func add_point():
	score +=1
	save_system.current_data.coins = score
	coins_label.text = "Coins: " + str(score)
