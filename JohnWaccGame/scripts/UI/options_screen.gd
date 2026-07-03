extends Control


# reference to the other screens
@onready var display_options_screen: Control = $display_options_screen
@onready var sound_options_screen: Control = $sound_options_screen
@onready var input_options_screen: Control = $input_options_screen
# reference to the display button
@onready var display_button: Button = $UI_elements/VBoxContainer2/VBoxContainer/DisplayButton


func focused():
	self.get_parent().release_focus()
	display_button.grab_focus()


# show the display options screen
func _on_display_button_pressed() -> void:
	display_options_screen.visible = true
	display_options_screen.focused()


# show the sound options screen
func _on_sound_button_pressed() -> void:
	sound_options_screen.visible = true
	sound_options_screen.focused()


# show the input options screen
func _on_input_button_pressed() -> void:
	input_options_screen.visible = true
	input_options_screen.focused()


# hides the options menu
func _on_back_button_pressed() -> void:
	self.visible = false
	self.get_parent().focused()
