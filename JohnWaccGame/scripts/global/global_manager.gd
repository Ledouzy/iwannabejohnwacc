extends Node

# location of the settings file
var settings_location = "user://settings.json"

# default settings for reseting (not implemented) or creating a new file
var default_settings = {
	"master": 0.4,
	"music": 1.0,
	"sfx": 1.0,
	"bgs": 1.0
}

# settings loaded from file
var loaded_settings = {
	"master": 0.4,
	"music": 1.0,
	"sfx": 1.0,
	"bgs": 1.0
}

# load settings from settings file
func load_settings():
	# if the file exists
	if FileAccess.file_exists(settings_location):
		# open the file and get the data
		var file = FileAccess.open(settings_location, FileAccess.READ)
		var data = file.get_var()
		
		# close the file
		file.close()
		
		# copy the data to settings_data
		var settings_data = data.duplicate()
		
		#print("Master: ", settings_data.master, " Music: ", settings_data.music, " SFX: ", settings_data.sfx, " BGS: ", settings_data.bgs)
		
		# change loaded settings to the data we just loaded
		loaded_settings.master = settings_data.master
		loaded_settings.music = settings_data.music
		loaded_settings.sfx = settings_data.sfx
		loaded_settings.bgs = settings_data.bgs
		
		# TODO: add the rest, like inputs, etc.
	else:
		# create the file and store the default settings
		var file = FileAccess.open(settings_location, FileAccess.WRITE)
		file.store_var(default_settings.duplicate())
		
		# close the file
		file.close()
		# copy the default settings to the loaded settings
		loaded_settings = default_settings.duplicate()
	
	# now that we loaded data, apply the changes
	
	# variable that we will reuse for the audio bus
	var bus_index
	
	# get the master bus and change its value to the loaded settings
	bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(loaded_settings.master))
	
	# same for music
	bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(loaded_settings.music))
	
	# same for sfx
	bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(loaded_settings.sfx))
	
	# same for bgs
	bus_index = AudioServer.get_bus_index("BGS")
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(loaded_settings.bgs))
	
# update the settings to new value
func update_settings():
	# variable that we will reuse for the audio bus
	var bus_index
	
	# get the master volume from the bus and change the loaded settings to that value
	bus_index = AudioServer.get_bus_index("Master")
	#print("Master: ", AudioServer.get_bus_volume_linear(bus_index))
	loaded_settings.master = AudioServer.get_bus_volume_linear(bus_index)
	
	# same for music
	bus_index = AudioServer.get_bus_index("Music")
	#print("Music: ", AudioServer.get_bus_volume_linear(bus_index))
	loaded_settings.music = AudioServer.get_bus_volume_linear(bus_index)
	
	# same for sfx
	bus_index = AudioServer.get_bus_index("SFX")
	#print("SFX: ", AudioServer.get_bus_volume_linear(bus_index))
	loaded_settings.sfx = AudioServer.get_bus_volume_linear(bus_index)
	
	# same for bgs
	bus_index = AudioServer.get_bus_index("BGS")
	#print("BGS: ", AudioServer.get_bus_volume_linear(bus_index))
	loaded_settings.bgs = AudioServer.get_bus_volume_linear(bus_index)
	
# save the loaded settings to the settings file
func save_settings():
	# open the file
	var file = FileAccess.open(settings_location, FileAccess.WRITE)
	# store the loaded data
	file.store_var(loaded_settings.duplicate())
	# close the file
	file.close()

func _ready() -> void:
	load_settings()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# if fullscreen key is pressed (F4), toggle on/off fullscreen
	if Input.is_action_just_pressed("fullscreen"):
		if (DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
