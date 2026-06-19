extends Control

@onready var options_screen: Control = $options_screen
@onready var credit_screen: Control = $credit_screen
@onready var start_button: Button = $UI_elements/VBoxContainer/VBoxContainer/StartButton
@onready var save_file_screen: Control = $SaveFileScreen

func _ready() -> void:
	# reset checkpoint upon arriving on title screen, TODO: Ask if we want to keep checkpoint maybe
	save_system.checkpoint_reset()
	
	# play the title music
	audio_manager.play_music("DivineBloodlines")
	# stop background sound
	audio_manager.stop_bgs()
	# focus the UI
	focused()

# make the buttons work on gamepad
func focused():
	# start button has focus
	start_button.grab_focus()

func _on_start_button_pressed() -> void:
	# show save file screen and focus it
	save_file_screen.visible = true
	save_file_screen.focused()


func _on_options_button_pressed() -> void:
	# show options screen and focus it
	options_screen.visible = true
	options_screen.focused()

func _on_credits_button_pressed() -> void:
	# show credits screen and focus it
	credit_screen.visible = true
	credit_screen.focused()

func _on_quit_button_pressed() -> void:
	# quit the game
	get_tree().quit()
