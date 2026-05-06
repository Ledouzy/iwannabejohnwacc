extends base_button

@onready var save_file: Control = $"../.."

func _on_pressed() -> void:
	super()
	save_system.delete(save_file.file_id)
