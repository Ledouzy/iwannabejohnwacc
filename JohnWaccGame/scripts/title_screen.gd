extends Control

@onready var options_screen: Control = $options_screen
@onready var credit_screen: Control = $credit_screen

func _on_start_button_pressed() -> void:
	print("pressed")
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_options_button_pressed() -> void:
	options_screen.visible = true

func _on_credits_button_pressed() -> void:
	credit_screen.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()
