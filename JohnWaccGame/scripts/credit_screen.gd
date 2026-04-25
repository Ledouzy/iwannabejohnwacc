extends Control

func _on_back_button_pressed() -> void:
	self.visible = false
	self.get_parent().focused()
