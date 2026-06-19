extends Node

var loaded_save_location = "user://file0.json" # base loaded save location
var save_location = "user://file0.json" # base save location
var load_lock = Mutex.new() # lock so that only one thread can load data from a save file

# for the save menu
var loaded_data: Dictionary = { 
	"name": "Jack", # pretty much will always be jack, except if we add different characters
	"stage": 0, # levels will be in order 0,1,2,3,4 but will be converted into 1-1, 1-2, 1-3, 1-4, 2-1, etc.
	"armor": false, # indicates sprite for armor, TODO: change sprite if this is true
	"jump_boots": false, # allows for 2 jumps, TODO: implement this
	"hookshot": false, # allows for hookshot, TODO: implement this
	"sword": false, # allows for sword, TODO: implement this
	"MAX_HP": 6, # number of HP
	"coins": 0, # number of coins
	"Lives": 3, # number of lives
	"deeple_fire": false, # fire deeple
	"deeple_earth": false, # earth deeple
	"deeple_wind": false, # wind deeple
	"deeple_water": false, # water deeple
	"number_of_deeples": 0, # number of total deeple
	"game_complete": false, # if done, allow for level select
	"score": 0 # no clue if we're going to use this
}

# data of the current game
var current_data: Dictionary = {
	"name": "Jack",
	"stage": 0, 
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

# for checkpoints
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


# load a specific save file
func select_save_file(file_id: int):
	if file_id >= 0 and file_id < 3: # between 0 and 2, for 3 save files
		# changes the save file to this
		loaded_save_location = "user://file" + str(file_id) + ".json"


# save the current data to the save file
func _save():
	# open the save file
	var file = FileAccess.open(save_location, FileAccess.WRITE)
	
	# copy the new values and close the file
	file.store_var(current_data.duplicate())
	file.close()
	
	# debug message
	print("save_location: ", save_location)
	
	
# load the data for the save data menu
func _load_data(file_id: int):
	# make sure that only one thread can do this section
	load_lock.lock()
	# select the data that we want to display
	select_save_file(file_id)
	
	# if the file exists for the save data
	if FileAccess.file_exists(loaded_save_location):
		# open that file
		var file = FileAccess.open(loaded_save_location, FileAccess.READ)
		# get the data
		var data = file.get_var()
		# close the file
		file.close()
		
		# copy the data to save data
		var save_data = data.duplicate()
		
		# make loaded data have the value from the file
		loaded_data.name = save_data.name
		loaded_data.stage = save_data.stage
		loaded_data.coins = save_data.coins
		# TODO: add the rest
		
		# release the lock
		load_lock.unlock()
		
		# return the data
		return loaded_data # load successful
	# release the data
	load_lock.unlock()
	
	# load failed, create new save file
	return null 


# load the data from the file
func _load(file_id: int):
	# lock for no conflict
	load_lock.lock()
	
	# debug message
	print("loading file id: ", file_id)
	
	# load the data
	var data = _load_data(file_id)
	
	# if we actually found a save file
	if data != null:
		# make current data the data we got
		current_data = data
		# chagne the save_location
		save_location = loaded_save_location
	
	# release the lock
	load_lock.unlock()
	

# create new save data
func create_new_save(file_id):
	# reset the current data
	current_data = {
		"name": "Jack",
		"stage": 0, 
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
	
	# select the save file we're creating
	select_save_file(file_id)
	
	# update save location to the loaded save location
	save_location = loaded_save_location
	
	# save to make sure the file is created and updated
	_save()
	# load the data to avoid any fuck up
	_load(file_id)
	
	
# delete the selected save file
func delete(file_id):
	# DELETE
	DirAccess.remove_absolute("user://file" + str(file_id) + ".json")


# save for checkpoints
func checkpoint_save(x_coords: float, y_coords):
	print("Checkpoint Save!")
	
	# copy current data to the checkpoint and the xy coords
	checkpoint_data = current_data.duplicate()
	checkpoint_data.x_coords = x_coords
	checkpoint_data.y_coords = y_coords 


# load the data from the checkpoint data
func checkpoint_load(player: CharacterBody2D):
	print("loading checkpoint data")
	#print("old coins: ", current_data.coins)
	#print("checkpoint coins:", checkpoint_data.coins)
	
	# copy checkpoint data to the current data
	current_data = checkpoint_data.duplicate()
	
	# remove x and y coords, we don'T need those
	current_data.erase("x_coords")
	current_data.erase("y_coords")
	
	# change player position
	player.position = Vector2(checkpoint_data.x_coords, checkpoint_data.y_coords)
	#print("player position: ", player.position)
	#print("current coins:", current_data.coins)


# resets data for the checkpoint
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
