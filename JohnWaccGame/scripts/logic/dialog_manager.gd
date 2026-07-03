extends Node


# the file where the dialogue is stored
@export_file("*.json") var scene_text_file

# the list of text lines in the scene loaded from the file
var scene_text = {}
# the text that is displayed
var selected_text = []
# currently in a dialogue
var in_progress = false

# reference to the dialogue box where text is displayed
@onready var dialog_box: Control = $CanvasLayer/DialogBox


# toggle on the dialog box
func toggle_on_dialog_box():
	dialog_box.toggle_on_dialog_box()


# toggle off the dialog box
func toggle_off_dialog_box():
	dialog_box.toggle_off_dialog_box()


# display the text with the portrait indicated
func display_text(text: String, portrait_name: String = ""):
	# if no portrait mentionned
	if portrait_name == "":
		# display without portrait
		dialog_box.display_text(text)
	else:
		# display with portrait
		dialog_box.display_text_portrait(text, portrait_name)


# load the text for the scene
func load_scene_text():
	# try to open the file scene_text_file
	var file_text = FileAccess.get_file_as_string(scene_text_file)
	# if not found, return and print error
	if file_text == null || file_text == "":
		print("Couldn't find text file \"", scene_text_file, "\".")
		return
	# return the content of the JSON file
	return JSON.parse_string(file_text)


# displays the next line
func next_line():
	# if there is text left,
	if selected_text.size() > 0:
		# get the next line and display it
		var next_line = selected_text.pop_front()
		var text = next_line.text
		var portrait = null
		
		# if there is a portrait specified, make portrait equal to it
		if next_line.portrait:
			portrait = next_line.portrait
		
		# if we don't have a portrait, call without portrait
		if portrait == null:
			display_text(text)
		else:
			# else call with
			display_text(text, portrait)
	else:
		# end the dialogue
		finish()


# manage the end of dialogue
func finish():
	# reset the dialogue box text to "".
	display_text("")
	# toggle off the dialog box
	toggle_off_dialog_box()
	# mark that we are not in a dialogue
	in_progress = false
	# unpause the game
	get_tree().paused = false


# when get signal to display dialog
func _on_display_dialog(text_key):
	# if we are in a text box already
	if in_progress:
		# if the dialog is done being displayed
		if dialog_box.is_done():
			# display next line
			next_line()
		else:
			# show the entire text
			dialog_box.set_skip_text()
	else: 
		# pause the game
		get_tree().paused = true
		# toggle on the dialog box
		toggle_on_dialog_box()
		# mark that we are in a dialogue
		in_progress = true
		# create a copy of the dialogue we want to display
		selected_text = scene_text[text_key].duplicate()
		# display the next line
		next_line()


func _ready():
	# make sure the dialogue box is turned off
	dialog_box.toggle_off_dialog_box()
	# get the text for the scene
	scene_text = load_scene_text()
	# connect pressing the dialog key next to an npc to the on display dialog method
	SignalBus.display_dialog.connect(_on_display_dialog)
