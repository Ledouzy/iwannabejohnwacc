extends Control

# buttons
@onready var back_button: Button = $UI_elements/MarginContainer/VBoxContainer2/HBoxContainer/BackButton
@onready var level_select_button: base_button = $UI_elements/MarginContainer/VBoxContainer2/HBoxContainer/LevelSelectButton

# save files
@onready var save_file_0: Control = $UI_elements/MarginContainer/VBoxContainer2/VBoxContainer/SaveFile0
@onready var save_file_1: Control = $UI_elements/MarginContainer/VBoxContainer2/VBoxContainer/SaveFile1
@onready var save_file_2: Control = $UI_elements/MarginContainer/VBoxContainer2/VBoxContainer/SaveFile2

# level select screen
@onready var level_select: Control = $LevelSelect


func _ready() -> void:
	# load data for all save files and display their data
	var file0 = save_system._load_data(0)
	save_file_0.display_save_data(file0)
	
	var file1 = save_system._load_data(1)
	save_file_1.display_save_data(file1)
	
	var file2 = save_system._load_data(2)
	save_file_2.display_save_data(file2)
	
	# change the focus neighbors for the buttons so that menu with controller works
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
	# update the save files with the new info
	var file0 = save_system._load_data(0)
	save_file_0.display_save_data(file0)
	
	var file1 = save_system._load_data(1)
	save_file_1.display_save_data(file1)
	
	var file2 = save_system._load_data(2)
	save_file_2.display_save_data(file2)


# give focus to the back button
func focused():
	self.get_parent().release_focus()
	back_button.grab_focus()

# hide window and give focus to parent
func _on_back_button_pressed() -> void:
	self.visible = false
	self.get_parent().focused()


# show level select screen and give focus to it
func _on_level_select_button_pressed() -> void:
	level_select.visible = true
	level_select.focused()
