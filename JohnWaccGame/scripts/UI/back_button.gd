extends base_button

## Back Button - By Ledouzy
## Same as a Base Button but plays the ui_back sfx instead.


## just plays the ui_back sfx on press
func _on_pressed() -> void:
	audio_manager.play_ui_back()
