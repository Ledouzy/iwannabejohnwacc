extends Node

var loaded_save_location = "user://file0.json"
var save_location = "user://file0.json"
var load_lock = Mutex.new()

var loaded_data: Dictionary = { # for the save menu
	"name": "Jack",
	"stage": 0, # levels will be in order 0,1,2,3,4 but will be converted into 1-1, 1-2, 1-3, 1-4, 2-1, etc.
	"armor": false,
	"jump_boots": false,
	"hookshot": false,
	"sword": false,
	"MAX_HP": 6,
	"coins": 0,
	"Lives": 3,
	"deeple_fire": false,
	"deeple_earth": false,
	"deeple_wind": false,
	"deeple_water": false,
	"number_of_deeples": 0,
	"game_complete": false,
	"score": 0 # no clue if we're going to use this
}

var current_data: Dictionary = { # data of the current game
	"name": "Jack",
	"stage": 0, # levels will be in order 0,1,2,3,4 but will be converted into 1-1, 1-2, 1-3, 1-4, 2-1, etc.
	"armor": false,
	"jump_boots": false,
	"hookshot": false,
	"sword": false,
	"MAX_HP": 6,
	"coins": 0,
	"Lives": 3,
	"deeple_fire": false,
	"deeple_earth": false,
	"deeple_wind": false,
	"deeple_water": false,
	"number_of_deeples": 0,
	"game_complete": false,
	"score": 0 # no clue if we're going to use this
}

var checkpoint_data: Dictionary = {
	"name": "Jack",
	"stage": 0, # levels will be in order 0,1,2,3,4 but will be converted into 1-1, 1-2, 1-3, 1-4, 2-1, etc.
	"armor": false,
	"jump_boots": false,
	"hookshot": false,
	"sword": false,
	"MAX_HP": 6,
	"coins": 0,
	"Lives": 3,
	"deeple_fire": false,
	"deeple_earth": false,
	"deeple_wind": false,
	"deeple_water": false,
	"number_of_deeples": 0,
	"game_complete": false,
	"score": 0, # no clue if we're going to use this
	# Checkpoint specific data
	"x_coords": 0.0,
	"y_coords": 0.0,
}

func select_save_file(file_id: int):
	if file_id >= 0 and file_id < 3: # between 0 and 2, for 3 save files
		loaded_save_location = "user://file" + str(file_id) + ".json"

func _save():
	var file = FileAccess.open(save_location, FileAccess.WRITE)
	file.store_var(current_data.duplicate())
	file.close()
	print("save_location: ", save_location)
	
func _load_data(file_id: int):
	load_lock.lock()
	select_save_file(file_id)
	
	if FileAccess.file_exists(loaded_save_location):
		var file = FileAccess.open(loaded_save_location, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		var save_data = data.duplicate()
		loaded_data.name = save_data.name
		loaded_data.stage = save_data.stage
		loaded_data.coins = save_data.coins
		# TODO: add the rest
		
		load_lock.unlock()
		return loaded_data # load successful
		
	load_lock.unlock()
	return null # load failed, create new save file
	
func _load(file_id: int):
	load_lock.lock()
	
	print("loading file id: ", file_id)
	var data = _load_data(file_id)
	if data != null:
		current_data = data
		save_location = loaded_save_location
		print("load_location: ", save_location)
		
	load_lock.unlock()
	
	
func create_new_save(file_id):
	current_data = {
		"name": "Jack",
		"stage": 0,
		"armor": false,
		"jump_boots": false,
		"hookshot": false,
		"sword": false,
		"MAX_HP": 6,
		"coins": 0,
	}
	select_save_file(file_id)
	save_location = loaded_save_location
	_save()
	_load(file_id)
	
func delete(file_id):
	DirAccess.remove_absolute("user://file" + str(file_id) + ".json")
	
func checkpoint_save(x_coords: float, y_coords):
	print("Checkpoint Save!")
	
	checkpoint_data = current_data.duplicate()
	checkpoint_data.x_coords = x_coords
	checkpoint_data.y_coords = y_coords 
	
func checkpoint_load(player: CharacterBody2D):
	print("loading checkpoint data")
	
	current_data = checkpoint_data.duplicate()
	current_data.erase("x_coords")
	current_data.erase("y_coords")
	
	player.position = Vector2(checkpoint_data.x_coords, checkpoint_data.y_coords)
	print("player position: ", player.position)
	
func checkpoint_reset():
	checkpoint_data = {
	"name": "Jack",
	"stage": 0, # levels will be in order 0,1,2,3,4 but will be converted into 1-1, 1-2, 1-3, 1-4, 2-1, etc.
	"armor": false,
	"jump_boots": false,
	"hookshot": false,
	"sword": false,
	"MAX_HP": 6,
	"coins": 0,
	"Lives": 3,
	"deeple_fire": false,
	"deeple_earth": false,
	"deeple_wind": false,
	"deeple_water": false,
	"number_of_deeples": 0,
	"game_complete": false,
	"score": 0, # no clue if we're going to use this
	# Checkpoint specific data
	"x_coords": 0.0,
	"y_coords": 0.0,
}
