extends base_button

@onready var save_file: Control = $"../.."

# on pressed
func _on_pressed() -> void:
	# call the base button version
	super()
	# delete the save file
	save_system.delete(save_file.file_id)
