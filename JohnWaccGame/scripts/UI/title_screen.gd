extends Control

@onready var options_screen: Control = $options_screen
@onready var credit_screen: Control = $credit_screen
@onready var start_button: Button = $UI_elements/VBoxContainer/VBoxContainer/StartButton

func focused():
	start_button.grab_focus()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/game.tscn")


func _on_options_button_pressed() -> void:
	options_screen.visible = true
	options_screen.focused()

func _on_credits_button_pressed() -> void:
	credit_screen.visible = true
	credit_screen.focused()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
