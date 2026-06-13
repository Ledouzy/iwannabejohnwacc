extends Area2D

# index/key in the dictionary that we want to look up
@export var dialog_key = ""
# are we in the area to trigger the dialogue
var area_active = false

func _input(event: InputEvent) -> void:
	# if the input we pressed is interact and the area is active
	if area_active and event.is_action_pressed("interact"):
		# display dialogue
		SignalBus.emit_signal("display_dialog", dialog_key)

# in the area, thus we can trigger the dialogue
func _on_area_entered(area: Area2D) -> void:
	area_active = true

# left, so disable the trigger for the dialogue
func _on_area_exited(area: Area2D) -> void:
	area_active = false
