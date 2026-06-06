extends Node

var settings_location = "user://settings.json"

var default_settings = {
	"master": 0.4,
	"music": 1.0,
	"sfx": 1.0,
	"bgs": 1.0
}

var loaded_settings = {
	"master": 0.4,
	"music": 1.0,
	"sfx": 1.0,
	"bgs": 1.0
}

func load_settings():
	if FileAccess.file_exists(settings_location):
		var file = FileAccess.open(settings_location, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		var settings_data = data.duplicate()
		
		#print("Master: ", settings_data.master, " Music: ", settings_data.music, " SFX: ", settings_data.sfx, " BGS: ", settings_data.bgs)
		
		loaded_settings.master = settings_data.master
		loaded_settings.music = settings_data.music
		loaded_settings.sfx = settings_data.sfx
		loaded_settings.bgs = settings_data.bgs
	# TODO: add the rest
	else:
		var file = FileAccess.open(settings_location, FileAccess.WRITE)
		file.store_var(default_settings.duplicate())
		file.close()
		loaded_settings = default_settings.duplicate()
	# now that we loaded data, apply the changes
	var bus_index
	
	bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(loaded_settings.master))
	
	bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(loaded_settings.music))
	
	bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(loaded_settings.sfx))
	
	bus_index = AudioServer.get_bus_index("BGS")
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(loaded_settings.bgs))
	
func update_settings():
	var bus_index
	
	bus_index = AudioServer.get_bus_index("Master")
	#print("Master: ", AudioServer.get_bus_volume_linear(bus_index))
	loaded_settings.master = AudioServer.get_bus_volume_linear(bus_index)
	
	bus_index = AudioServer.get_bus_index("Music")
	#print("Music: ", AudioServer.get_bus_volume_linear(bus_index))
	loaded_settings.music = AudioServer.get_bus_volume_linear(bus_index)
	
	bus_index = AudioServer.get_bus_index("SFX")
	#print("SFX: ", AudioServer.get_bus_volume_linear(bus_index))
	loaded_settings.sfx = AudioServer.get_bus_volume_linear(bus_index)
	
	bus_index = AudioServer.get_bus_index("BGS")
	#print("BGS: ", AudioServer.get_bus_volume_linear(bus_index))
	loaded_settings.bgs = AudioServer.get_bus_volume_linear(bus_index)
	
func save_settings():
	var file = FileAccess.open(settings_location, FileAccess.WRITE)
	file.store_var(loaded_settings.duplicate())
	file.close()

func _ready() -> void:
	load_settings()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("fullscreen"):
		if (DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
