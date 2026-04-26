extends Control

var score = 0
@onready var coins_label: Label = $CanvasLayer/Base/MarginContainer/HBoxContainer/CoinsLabel
@onready var health_label: Label = $CanvasLayer/Base/MarginContainer/HBoxContainer/HealthLabel
@onready var player: CharacterBody2D = $"../Player"
@onready var pause_menu: Control = $CanvasLayer/pause_menu

func _ready() -> void:
	coins_label.text = "Coins: " + str(score)
	health_label.text = "Health: " + str(player.get_health()) + "/" + str(player.get_max_health())
	
func _process(delta: float) -> void:
	#coins_label.text = "Coins: " + str(score)
	health_label.text = "Health: " + str(player.get_health()) + "/" + str(player.get_max_health())
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		pause_menu.visible = true

func add_point():
	score +=1
	coins_label.text = "Coins: " + str(score)
