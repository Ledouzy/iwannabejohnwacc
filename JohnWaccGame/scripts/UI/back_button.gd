extends base_button


## just plays the ui_back sfx on press
func _on_pressed() -> void:
	audio_manager.play_ui_back()
