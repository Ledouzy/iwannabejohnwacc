extends Control

var score = 0
@onready var label: Label = $CanvasLayer/Base/HBoxContainer/Label
@onready var player: CharacterBody2D = $"../Player"

func _ready() -> void:
	label.text = "Coins: " + str(score) + "\t Health: " + str(player.get_health()) + "/" + str(player.get_max_health())
	
func update_health():
	label.text = "Coins: " + str(score) + "\t Health: " + str(player.get_health()) + "/" + str(player.get_max_health())

func add_point():
	score +=1
	label.text = "Coins: " + str(score) + "\t Health: " + str(player.get_health()) + "/" + str(player.get_max_health())
