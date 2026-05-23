extends Node

@export_file("*.json") var scene_text_file

var scene_text = {}
var selected_text = []
var in_progress = false

@onready var dialog_box: Control = $CanvasLayer/DialogBox

func toggle_on_dialog_box():
	dialog_box.toggle_on_dialog_box()
	
func toggle_off_dialog_box():
	dialog_box.toggle_off_dialog_box()
	
func display_text(text: String, portrait_name: String = ""):
	if portrait_name == "":
		dialog_box.display_text(text)
	else:
		dialog_box.display_text_portrait(text, portrait_name)

func _ready():
	dialog_box.toggle_off_dialog_box()
	scene_text = load_scene_text()
	SignalBus.display_dialog.connect(_on_display_dialog)
	
func load_scene_text():
	var file_text = FileAccess.get_file_as_string(scene_text_file)
	if file_text == null || file_text == "":
		return
	return JSON.parse_string(file_text)
	
func next_line():
	if selected_text.size() > 0:
		var text = selected_text.pop_front()
		display_text(text)
	else:
		finish()
		
func finish():
	display_text("")
	toggle_off_dialog_box()
	in_progress = false
	get_tree().paused = false
	
func _on_display_dialog(text_key):
	if in_progress:
		if dialog_box.is_done():
			next_line()
		else:
			dialog_box.set_skip_text()
	else: 
		get_tree().paused = true
		toggle_on_dialog_box()
		in_progress = true
		selected_text = scene_text[text_key].duplicate()
		next_line()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug") && dialog_box.visible == false:
		toggle_on_dialog_box()
	elif Input.is_action_just_pressed("debug") && dialog_box.visible == true:
		toggle_off_dialog_box()
