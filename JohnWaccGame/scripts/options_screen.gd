extends Control

@onready var display_options_screen: Control = $display_options_screen
@onready var sound_options_screen: Control = $sound_options_screen
@onready var input_options_screen: Control = $input_options_screen
@onready var display_button: Button = $UI_elements/VBoxContainer2/VBoxContainer/DisplayButton

func focused():
	display_button.grab_focus()

func _on_display_button_pressed() -> void:
	display_options_screen.visible = true
	display_options_screen.focused()


func _on_sound_button_pressed() -> void:
	sound_options_screen.visible = true
	sound_options_screen.focused()

func _on_input_button_pressed() -> void:
	input_options_screen.visible = true
	input_options_screen.focused()


func _on_back_button_pressed() -> void:
	self.visible = false
	self.get_parent().focused()
