extends base_button

## UNUSED: This is a debug script for a button intended to test the ability to save data


func _on_pressed() -> void:
	# call the function in base button
	super()
	
	# select the current save file to load from
	save_system.select_save_file(0)
	# save the stage to be 0
	#save_system.contents.stage = 0
	# save the information
	save_system._save()
