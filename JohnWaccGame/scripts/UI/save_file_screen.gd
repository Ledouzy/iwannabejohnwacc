extends Control

@onready var back_button: Button = $UI_elements/MarginContainer/VBoxContainer2/BackButton

@onready var save_file_0: Control = $UI_elements/MarginContainer/VBoxContainer2/VBoxContainer/SaveFile0
@onready var save_file_1: Control = $UI_elements/MarginContainer/VBoxContainer2/VBoxContainer/SaveFile1
@onready var save_file_2: Control = $UI_elements/MarginContainer/VBoxContainer2/VBoxContainer/SaveFile2


func _ready() -> void:
	var file0 = save_system._load(0)
	save_file_0.display_save_data(file0)
	
	var file1 = save_system._load(1)
	save_file_1.display_save_data(file1)
	
	var file2 = save_system._load(2)
	save_file_2.display_save_data(file2)

func focused():
	self.get_parent().release_focus()
	back_button.grab_focus()

func _on_back_button_pressed() -> void:
	self.visible = false
	self.get_parent().focused()
