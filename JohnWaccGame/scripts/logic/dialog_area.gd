extends Area2D

# index/key in the dictionary that we want to look up
@export var dialog_key = ""
@export var one_time_dialog = false
# are we in the area to trigger the dialogue
var area_active = false
var end_connected = false

func _input(event: InputEvent) -> void:
	# if the input we pressed is interact and the area is active
	if area_active and event.is_action_pressed("interact"):
		# connect the signal to dialog ended
		if !end_connected:
			end_connected = true
			SignalBus.end_dialog.connect(_on_dialog_ended)
			
		# display dialogue
		SignalBus.emit_signal("display_dialog", dialog_key)

# in the area, thus we can trigger the dialogue
func _on_area_entered(area: Area2D) -> void:
	area_active = true

# left, so disable the trigger for the dialogue
func _on_area_exited(area: Area2D) -> void:
	area_active = false

# either does nothing or removes the dialog if one time dialog
func _on_dialog_ended():
	SignalBus.end_dialog.disconnect(_on_dialog_ended)
	if one_time_dialog:
		queue_free()
