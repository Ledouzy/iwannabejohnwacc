extends Control

@export var text_display_speed = 0.02

var skip_text = false
var done = false

@onready var label: Label = $Label

func is_done():
	return done
	
func set_skip_text():
	skip_text = true

func display_text(text: String):
	done = false
	label.text = ""
	for c in text:
		if skip_text:
			break
		await get_tree().create_timer(text_display_speed).timeout
		label.text = label.text + c
	label.text = text
	skip_text = false
	done = true
		
func display_text_portrait(text: String, portrait_name: String):
	display_text(text)
		
func toggle_on_dialog_box():
	self.visible = true
	
func toggle_off_dialog_box():
	self.visible = false
