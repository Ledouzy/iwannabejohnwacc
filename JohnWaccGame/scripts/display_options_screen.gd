extends Control
@onready var check_box: CheckBox = $UI_elements/VBoxContainer2/Container/VBoxContainer/HSplitContainer/CheckBox
@onready var back_button: Button = $UI_elements/VBoxContainer2/VBoxContainer/BackButton

func focused():
	back_button.grab_focus()

func _process(delta) -> void:
	if (DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN):
		check_box.button_pressed = false
	else:
		check_box.button_pressed = true

func _on_back_button_pressed() -> void:
	self.visible = false
	self.get_parent().focused()

func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		#print("fullscreen")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		#print("windowed")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
