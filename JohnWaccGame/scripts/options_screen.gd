extends Control

@onready var display_options_screen: Control = $display_options_screen
@onready var sound_options_screen: Control = $sound_options_screen
@onready var input_options_screen: Control = $input_options_screen


func _on_display_button_pressed() -> void:
	display_options_screen.visible = true


func _on_sound_button_pressed() -> void:
	sound_options_screen.visible = true


func _on_input_button_pressed() -> void:
	input_options_screen.visible = true


func _on_back_button_pressed() -> void:
	self.visible = false
