class_name cutscene extends CanvasLayer

@export var dialog_key = ""

var end_connected = false

func move_sprite(sprite: TextureRect, new_coords: Vector2, time: float, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT):
	var tween = get_tree().create_tween()
	tween.set_trans(trans_type) 
	tween.set_ease(ease_type)
	tween.tween_property(sprite, "position", new_coords, time)

func play():
	SignalBus.emit_signal("display_dialog", dialog_key)
	
func _input(event: InputEvent) -> void:
	# if the input we pressed is interact and the area is active
	if event.is_action_pressed("interact"):
		# connect the signal to dialog ended
		if !end_connected:
			end_connected = true
			SignalBus.end_dialog.connect(_on_cutscene_end)
			
		# display dialogue
		SignalBus.emit_signal("display_dialog", dialog_key)
		
func _on_cutscene_end():
	SignalBus.emit_signal("end_cutscene")
	pass
