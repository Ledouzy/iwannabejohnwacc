extends Control


@onready var back_button: Button = $UI_elements/MarginContainer/VBoxContainer2/BackButton


# i don't need to explain shit about this script right?
func focused():
	self.get_parent().release_focus()
	back_button.grab_focus()


func _on_back_button_pressed() -> void:
	self.visible = false
	self.get_parent().focused()
