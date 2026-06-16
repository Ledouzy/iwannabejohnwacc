extends Node2D

# reference to the PlayerBody
@onready var player = $PlayerBody


# returns the PlayerBody
func get_player():
	return player
