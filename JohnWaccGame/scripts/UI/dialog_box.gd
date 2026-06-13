extends Control

# self explanatory
@export var text_display_speed = 0.02

# if true, displays the entire text
var skip_text = false
# if true, you can go to the next line
var done = false

# the text layer
@onready var label: Label = $Label

# returns the value of done
func is_done():
	return done

# changes skip text to true
func set_skip_text():
	skip_text = true

# displays text to the label
func display_text(text: String):
	# resets done back to false
	done = false
	# make the textbox empty
	label.text = ""
	
	# go over every character in the text we want to display
	for c in text:
		# if skip_text is true, then go out of the loop
		if skip_text:
			break
		# wait for a couple of milliseconds
		await get_tree().create_timer(text_display_speed).timeout
		# add the next character to the textbox
		label.text = label.text + c
	# when done, put the entirety of the text as the text of the textbox so that
	# when skipping dialogue it actually displays the entire text
	label.text = text
	
	# resets back skip_text to false
	skip_text = false
	# we are done
	done = true
		
# TODO: not currently implemented, just calls the normal method
func display_text_portrait(text: String, portrait_name: String):
	display_text(text)
		
# set the textbox to visible
func toggle_on_dialog_box():
	self.visible = true

# set the textbox to invisible
func toggle_off_dialog_box():
	self.visible = false
