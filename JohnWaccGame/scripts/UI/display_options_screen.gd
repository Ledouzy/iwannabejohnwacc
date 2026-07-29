extends Control

# buttons in the screen
@onready var fullscreen_check_box: CheckBox = $UI_elements/VBoxContainer2/Container/VBoxContainer/Fullscreen/CheckBox
@onready var aspect_check_box: CheckBox = $UI_elements/VBoxContainer2/Container/VBoxContainer/AspectRatio/CheckBox
@onready var back_button: Button = $UI_elements/VBoxContainer2/VBoxContainer/BackButton


# give focus to this screen
func focused():
	# make sure there's no fuckery going on
	self.get_parent().release_focus()
	# back button cuz we might add shit to the screen so better just put this for now
	back_button.grab_focus()


func _process(delta) -> void:
	# check settings and game to make sure the check box is accurate, there's probably a better way
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		fullscreen_check_box.button_pressed = false
	else:
		fullscreen_check_box.button_pressed = true
		
	# check aspect ratio to see if the check box is accurate
	if get_window().content_scale_size == Vector2i(256,144):
		aspect_check_box.button_pressed = true
	else:
		aspect_check_box.button_pressed = false
		

# hide the screen and give focus to the parent
func _on_back_button_pressed() -> void:
	self.visible = false
	self.get_parent().focused()


# toggle on fullscreen or off fullscreen
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		#print("fullscreen")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		#print("windowed")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	global_manager.update_settings()
	global_manager.save_settings()


func _on_widescreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# set window size to 256x144
		DisplayServer.window_set_size(Vector2i(256,144))
		get_window().content_scale_size = Vector2i(256,144)

	else:
		# set window size to 160x144
		DisplayServer.window_set_size(Vector2i(160,144))
		get_window().content_scale_size = Vector2i(160,144)
		
	global_manager.update_settings()
	global_manager.save_settings()
