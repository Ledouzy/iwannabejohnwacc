extends Control

var score = 0
@onready var label: Label = $CanvasLayer/Base/HBoxContainer/Label
@onready var player: CharacterBody2D = $"../Player"
@onready var pause_menu: Control = $CanvasLayer/pause_menu

func _ready() -> void:
	label.text = "Coins: " + str(score) + "\t Health: " + str(player.get_health()) + "/" + str(player.get_max_health())
	
func _process(delta: float) -> void:
	label.text = "Coins: " + str(score) + "\t Health: " + str(player.get_health()) + "/" + str(player.get_max_health())
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		pause_menu.visible = true

func add_point():
	score +=1
	label.text = "Coins: " + str(score) + "\t Health: " + str(player.get_health()) + "/" + str(player.get_max_health())
