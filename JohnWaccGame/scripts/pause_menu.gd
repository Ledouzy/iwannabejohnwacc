extends Control

@onready var options_screen: Control = $options_screen
var opened
@onready var resume_button: Button = $UI_elements/VBoxContainer2/VBoxContainer/ResumeButton

func focused():
	resume_button.grab_focus()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	self.visible = false

func _on_option_button_pressed() -> void:
	options_screen.visible = true
	options_screen.focused()

func _on_title_button_pressed() -> void:
	# probably have a confirmation popup
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if !opened:
			opened = true
			focused()
		else:
			opened = false
			_on_resume_button_pressed()
