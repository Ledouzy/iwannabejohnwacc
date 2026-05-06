extends base_button


func _on_pressed() -> void:
	super()
	save_system.select_save_file(0)
	save_system.contents.stage = 0
	save_system._save()
