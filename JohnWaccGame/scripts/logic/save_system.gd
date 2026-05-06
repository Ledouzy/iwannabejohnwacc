extends Node

var save_location = "user://file0.json"

var contents: Dictionary = {
	"stage": 0, # levels will be in order 0,1,2,3,4 but will be converted into 1-1, 1-2, 1-3, 1-4, 2-1, etc.
	"armor": false,
	"jump_boots": false,
	"hookshot": false,
	"sword": false,
	"MAX_HP": 6,
	"coins": 0,
}

func select_save_file(file_id: int):
	if file_id >= 0 and file_id < 3: # between 0 and 2, for 3 save files
		save_location = "user://file" + str(file_id) + ".json"

func _save():
	var file = FileAccess.open(save_location, FileAccess.WRITE)
	file.store_var(contents.duplicate())
	file.close()
	
func _load(file_id: int):
	select_save_file(file_id)
	
	if FileAccess.file_exists(save_location):
		var file = FileAccess.open(save_location, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		var save_data = data.duplicate()
		contents.stage = save_data.stage
		# add the rest
		
		return contents # load successful
		
	return null # load failed, create new save file
	
func create_new_save(file_id):
	contents = {
		"stage": 0,
		"armor": false,
		"jump_boots": false,
		"hookshot": false,
		"sword": false,
		"MAX_HP": 6,
		"coins": 0,
	}
	select_save_file(file_id)
	_save()
