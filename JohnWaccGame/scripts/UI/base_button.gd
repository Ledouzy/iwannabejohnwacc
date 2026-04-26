extends Button
class_name base_button

func _on_pressed() -> void:
	audio_manager.play_ui_confirm()


func _on_focus_entered() -> void:
	audio_manager.play_ui_move()


func _on_mouse_entered() -> void:
	audio_manager.play_ui_move()


func _on_toggled(toggled_on: bool) -> void:
	audio_manager.play_ui_confirm()
