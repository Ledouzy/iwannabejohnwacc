extends base_button

# Called when the node enters the scene tree for the first time.
# makes sure we can actually move using keyboard and controller
func _ready() -> void:
	grab_focus()
