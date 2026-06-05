extends HSlider

@export var bus_name: String

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	value = global_manager.loaded_settings.get(bus_name.to_lower())
	#AudioServer.set_bus_volume_db(bus_index,linear_to_db(value))
	
func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(value))
	print("changing ", bus_name, " to ", value)
	global_manager.update_settings()
	global_manager.save_settings()
