extends Button
class_name base_button

## plays the ui_confirm sfx on press
func _on_pressed() -> void:
	audio_manager.play_ui_confirm()

## plays the ui_move sfx on focus
func _on_focus_entered() -> void:
	audio_manager.play_ui_move()

## plays the ui_move sfx on hover
func _on_mouse_entered() -> void:
	audio_manager.play_ui_move()

## plays the ui_confirm sfx on toggle
func _on_toggled(toggled_on: bool) -> void:
	audio_manager.play_ui_confirm()
