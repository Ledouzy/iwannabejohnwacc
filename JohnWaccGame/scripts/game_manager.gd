extends Control

var score = 0
@onready var label: Label = $CanvasLayer/Base/HBoxContainer/Label

func add_point():
	score +=1
	label.text = "Coins: " + str(score)
