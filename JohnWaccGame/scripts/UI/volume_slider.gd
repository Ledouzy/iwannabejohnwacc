extends HSlider


# name of the bus we want to access
@export var bus_name: String

# the index of the bus we are accessing
var bus_index: int


func _ready() -> void:
	# get the bus index of the bus with the name bus_name
	bus_index = AudioServer.get_bus_index(bus_name)
	# connect the signal of changing value to on_value_changed
	value_changed.connect(_on_value_changed)
	
	# change the value of the slider to the value stored in the settings
	value = global_manager.loaded_settings.get(bus_name.to_lower())
	#AudioServer.set_bus_volume_db(bus_index,linear_to_db(value))


# when the value of the slider changes
func _on_value_changed(value: float) -> void:
	# play a sound to test out the volume of the corresponding audio bus
	if bus_name == "SFX" && self.get_tree().root.visible == true:
		audio_manager.play_sfx("Coin")
	elif bus_name == "BGS" && self.get_tree().root.visible == true:
		audio_manager.play_bgs("Test", 0.0, true)
	
	# change the volume of the audio bus to the value
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(value))
	
	# update the settings in memory and save it to disk
	global_manager.update_settings()
	global_manager.save_settings()
