extends Control

# is the menu opened
var opened : bool = false

# reference to the options screen
@onready var options_screen: Control = $options_screen
# reference to the resume button
@onready var resume_button: Button = $UI_elements/VBoxContainer2/MarginContainer/HBoxContainer/VBoxContainer/ResumeButton
# reference to the player
@onready var player = $"../../../Player"

func focused():
	resume_button.grab_focus()

func _on_resume_button_pressed() -> void:
	# unpause the game and hide the screen
	get_tree().paused = false
	self.visible = false

func _on_option_button_pressed() -> void:
	# show the options screen and focus it
	options_screen.visible = true
	options_screen.focused()

func _on_title_button_pressed() -> void:
	# TODO: probably have a confirmation popup
	# unpause the game
	get_tree().paused = false
	# load the title screen
	scene_manager.go_to_title(get_tree())

func _process(delta: float) -> void:
	# check for pause input
	if Input.is_action_just_pressed("pause"):
		if !opened:
			# if not opened, open it and focus the screen
			opened = true
			focused()
		else:
			# close the screen
			opened = false
			_on_resume_button_pressed()


func _on_retry_button_pressed() -> void:
	# reload the scene at the checkpoint and unpause the game
	scene_manager.reload_scene()
	get_tree().paused = false
