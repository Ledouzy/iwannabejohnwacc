extends Control

# id of the save file
@export var file_id = 0

# the data for the save file
var save_data
# list of all stage names corresponding to the id of the stage
var stage_names: Array = ["1-1","1-2","1-3","1-4","2-1","2-2","2-3","2-4","3-1","3-2","3-3","3-4","4-1","4-2","4-3","4-4","5-1","5-2","6-1","6-2"] # and so on and so forth, yeah it's shit

# save file components
@onready var file_name: Label = $HBoxContainer/Name
@onready var stage_label: Label = $HBoxContainer/Stage
@onready var play_button: base_button = $HBoxContainer/PlayButton
@onready var save_icon: TextureRect = $HBoxContainer/SaveIcon
@onready var spacer_2: Control = $HBoxContainer/Spacer2
@onready var spacer_3: Control = $HBoxContainer/Spacer3
@onready var spacer: Control = $HBoxContainer/Spacer
@onready var spacer_4: Control = $HBoxContainer/Spacer4
@onready var delete_button: Button = $HBoxContainer/DeleteButton


# display the data of the save file
func display_save_data(data):
	# if there is data
	if data != null:
		# save data is the data given
		save_data = data
		# update the stage text to the current level
		stage_label.text = str(stage_names[data.stage])
		# update the name of the save file
		file_name.text = data.name
	# if no save file
	else:
		# hide everything and change to a New Game button
		stage_label.text = ""
		stage_label.visible = false
		play_button.text = "New Game"
		save_icon.visible = false
		file_name.visible = false
		spacer.visible = false
		spacer_2.visible = false
		spacer_3.visible = false
		spacer_4.visible = false
		delete_button.visible = false
		save_data = null


func _on_play_button_pressed() -> void:
	# hides the screen
	self.get_parent().get_parent().visible = false
	
	# change current data to the selected save file
	save_system.select_save_file(file_id)
	
	# if no data
	if save_data == null:
		# create a new save data and load the first level
		save_system.create_new_save(file_id)
		scene_manager.load_level(0)
	else:
		# load data from the selected save file
		save_system._load(file_id)
		# load into correct scene
		scene_manager.load_level(save_data.stage)


# make sure that focus isn't lost
func _on_delete_button_pressed() -> void:
	play_button.grab_focus()
