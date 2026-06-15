extends Control

# the scene for the input remapping button
@onready var input_button_scene = preload("res://scenes/UI/input_button.tscn")

# the place where we put our actions to remap
@onready var action_list = $UI_elements/VBoxContainer2/VBoxContainer/MarginContainer/ScrollContainer/ActionList
# the back button
@onready var back_button: Button = $UI_elements/VBoxContainer2/VBoxContainer/HBoxContainer/BackButton

#  are we remapping right now
var is_remapping = false
# the action we are remapping
var action_to_remap = null
# the button of the action that we're remapping
var remapping_button = null

# the dictionary for the inputs and what they correspond to
var input_actions = {
	"up": "Up",
	"down": "Down",
	"left": "Left",
	"right": "Right",
	"run": "Run",
	"jump": "Jump",
	"attack": "Attack",
	"pick": "Pick/Throw",
}

# give focus to the screen
func focused():
	self.get_parent().release_focus()
	back_button.grab_focus()

func _ready() -> void:
	# create the action list for remapping
	_create_action_list()
	
# see above n'wah
func _create_action_list():
	# get the list of inputs
	InputMap.load_from_project_settings()
	
	for item in action_list.get_children():
		# flushes the current action list
		item.queue_free()
	
	for action in input_actions:
		# create a button and get the labels
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		# change the text for the action
		action_label.text = input_actions[action]
		
		# gets the events
		var events = InputMap.action_get_events(action)
		# for the name of the events, only get the first one, remove the suffixes, else change it to nothing
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" - Physical")
		else:
			input_label.text = ""
			
		# add that button to the list
		action_list.add_child(button)
		# connect it to the action of rebinding
		button.pressed.connect(_on_input_button_pressed.bind(button, action))

# upon pressing the button
func _on_input_button_pressed(button, action):
	# if we are not already remapping
	if !is_remapping:
		# we are remapping
		is_remapping = true
		# this is the action to remap
		action_to_remap = action
		# this is the button we are remapping to
		remapping_button = button
		# change the text to ...
		button.find_child("LabelInput").text = "..."

# on any input
func _input(event):
	# if we are remapping
	if is_remapping:
		# if the event is an inputeventkey or a mouse button
		if (event is InputEventKey || (event is InputEventMouseButton && event.pressed)):
			# Turn double click into single click
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			
			# erase the events already mapped
			InputMap.action_erase_events(action_to_remap)
			# add the new keybind to the events list for the action
			InputMap.action_add_event(action_to_remap, event)
			# update the action list
			_update_action_list(remapping_button, event)
			
			# we are not remapping anymore
			is_remapping = false
			# remove the action and button that we are remapping to be sure
			action_to_remap = null
			remapping_button = null
			
			# make sure the event doesn't get detected by something else
			accept_event()
			
# update the action list to reflect the new event linked to the action
func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" - Physical")

func _on_back_button_pressed() -> void:
	# can't go out of menu until we've finished remapping
	if !is_remapping: 
		# give focus to the parent and hide screen
		self.visible = false
		self.get_parent().focused()

# if we reset, just give back the original action list
func _on_reset_button_pressed() -> void:
	_create_action_list()
