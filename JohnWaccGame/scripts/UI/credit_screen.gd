extends Control

@onready var back_button: Button = $UI_elements/VBoxContainer2/VBoxContainer/BackButton

# focus the first button of the screen to allow for keyboard/controller input
func focused():
	self.get_parent().release_focus()
	back_button.grab_focus()

func _on_back_button_pressed() -> void:
	self.visible = false
	self.get_parent().focused()
