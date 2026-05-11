extends Control

@onready var options_screen: Control = $options_screen
var opened
@onready var resume_button: Button = $UI_elements/VBoxContainer2/VBoxContainer/ResumeButton
@onready var player = $"../../../Player"

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
	scene_manager.go_to_title(get_tree())

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if !opened:
			opened = true
			focused()
		else:
			opened = false
			_on_resume_button_pressed()


func _on_retry_button_pressed() -> void:
	#if player != null:
	#	save_system.checkpoint_load(player)
	#else:
	#	print("player is null")
	
	scene_manager.reload_scene()
	get_tree().paused = false
