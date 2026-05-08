extends Control

@onready var options_screen: Control = $options_screen
@onready var credit_screen: Control = $credit_screen
@onready var start_button: Button = $UI_elements/VBoxContainer/VBoxContainer/StartButton
@onready var save_file_screen: Control = $SaveFileScreen

func _ready() -> void:
	# reset checkpoint upon arriving on title screen, TODO: Ask if we want to keep checkpoint maybe
	save_system.checkpoint_reset()
	
	audio_manager.play_music("DivineBloodlines")
	focused()

func focused():
	start_button.grab_focus()

func _on_start_button_pressed() -> void:
	save_file_screen.visible = true
	save_file_screen.focused()


func _on_options_button_pressed() -> void:
	options_screen.visible = true
	options_screen.focused()

func _on_credits_button_pressed() -> void:
	credit_screen.visible = true
	credit_screen.focused()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
