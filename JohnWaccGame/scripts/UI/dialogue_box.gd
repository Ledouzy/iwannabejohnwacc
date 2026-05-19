extends Control

@onready var label: Label = $Label

func display_text(text: String):
	label.text = ""
	for c in text:
		await get_tree().create_timer(0.1).timeout
		label.text = label.text + c
		
func toggle_on_dialogue_box():
	self.visible = true
	
func toggle_off_dialogue_box():
	self.visible = false
