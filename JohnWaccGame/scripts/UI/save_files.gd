extends Control

@onready var file_name: Label = $HBoxContainer/Name
@onready var stage_label: Label = $HBoxContainer/Stage
@onready var play_button: base_button = $HBoxContainer/PlayButton
@onready var save_icon: TextureRect = $HBoxContainer/SaveIcon
@onready var spacer_2: Control = $HBoxContainer/Spacer2
@onready var spacer_3: Control = $HBoxContainer/Spacer3
@onready var spacer: Control = $HBoxContainer/Spacer

var level_names: Array = ["1-1","1-2","1-3","1-4","2-1"] # and so on and so forth, yeah it's shit

func display_save_data(data):
	if data != null:
		stage_label.text = str(level_names[data.stage])
	else:
		stage_label.text = ""
		stage_label.visible = false
		play_button.text = "New Game"
		save_icon.visible = false
		file_name.visible = false
		spacer.visible = false
		spacer_2.visible = false
		spacer_3.visible = false

func _on_play_button_pressed() -> void:
	scene_manager.change_scene(get_tree(), "game")
