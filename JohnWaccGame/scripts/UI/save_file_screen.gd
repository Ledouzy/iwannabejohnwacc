extends Control

@onready var back_button: Button = $UI_elements/MarginContainer/VBoxContainer2/HBoxContainer/BackButton
@onready var level_select_button: base_button = $UI_elements/MarginContainer/VBoxContainer2/HBoxContainer/LevelSelectButton

@onready var save_file_0: Control = $UI_elements/MarginContainer/VBoxContainer2/VBoxContainer/SaveFile0
@onready var save_file_1: Control = $UI_elements/MarginContainer/VBoxContainer2/VBoxContainer/SaveFile1
@onready var save_file_2: Control = $UI_elements/MarginContainer/VBoxContainer2/VBoxContainer/SaveFile2

@onready var level_select: Control = $LevelSelect

func _ready() -> void:
	var file0 = save_system._load_data(0)
	save_file_0.display_save_data(file0)
	
	var file1 = save_system._load_data(1)
	save_file_1.display_save_data(file1)
	
	var file2 = save_system._load_data(2)
	save_file_2.display_save_data(file2)
	
	back_button.focus_neighbor_top = NodePath(str(save_file_2.get_path())+"/HBoxContainer/PlayButton")
	back_button.focus_neighbor_bottom = NodePath(str(save_file_0.get_path())+"/HBoxContainer/PlayButton")
	
	level_select_button.focus_neighbor_top = NodePath(str(save_file_2.get_path())+"/HBoxContainer/PlayButton")
	level_select_button.focus_neighbor_bottom = NodePath(str(save_file_0.get_path())+"/HBoxContainer/PlayButton")
	
	get_node(str(save_file_0.get_path())+"/HBoxContainer/PlayButton").focus_neighbor_top = back_button.get_path()
	get_node(str(save_file_0.get_path())+"/HBoxContainer/PlayButton").focus_neighbor_bottom = NodePath(str(save_file_1.get_path())+"/HBoxContainer/PlayButton")
	
	get_node(str(save_file_1.get_path())+"/HBoxContainer/PlayButton").focus_neighbor_top = NodePath(str(save_file_0.get_path())+"/HBoxContainer/PlayButton")
	get_node(str(save_file_1.get_path())+"/HBoxContainer/PlayButton").focus_neighbor_bottom = NodePath(str(save_file_2.get_path())+"/HBoxContainer/PlayButton")
	
	get_node(str(save_file_2.get_path())+"/HBoxContainer/PlayButton").focus_neighbor_top = NodePath(str(save_file_1.get_path())+"/HBoxContainer/PlayButton")
	get_node(str(save_file_2.get_path())+"/HBoxContainer/PlayButton").focus_neighbor_bottom = back_button.get_path()

func _process(delta):
	var file0 = save_system._load_data(0)
	save_file_0.display_save_data(file0)
	
	var file1 = save_system._load_data(1)
	save_file_1.display_save_data(file1)
	
	var file2 = save_system._load_data(2)
	save_file_2.display_save_data(file2)

func focused():
	self.get_parent().release_focus()
	back_button.grab_focus()

func _on_back_button_pressed() -> void:
	self.visible = false
	self.get_parent().focused()


func _on_level_select_button_pressed() -> void:
	level_select.visible = true
	level_select.focused()
