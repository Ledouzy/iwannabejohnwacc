extends Control

# buttons in the screen
@onready var check_box: CheckBox = $UI_elements/VBoxContainer2/Container/VBoxContainer/HSplitContainer/CheckBox
@onready var back_button: Button = $UI_elements/VBoxContainer2/VBoxContainer/BackButton

# give focus to this screen
func focused():
	# make sure there's no fuckery going on
	self.get_parent().release_focus()
	# back button cuz we might add shit to the screen so better just put this for now
	back_button.grab_focus()

func _process(delta) -> void:
	# check settings and game to make sure the check is accurate, there's probably a better way
	if (DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN):
		check_box.button_pressed = false
	else:
		check_box.button_pressed = true

# hide the screen and give focus to the parent
func _on_back_button_pressed() -> void:
	self.visible = false
	self.get_parent().focused()

# toggle on fullscreen or off fullscreen
func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		#print("fullscreen")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		#print("windowed")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
