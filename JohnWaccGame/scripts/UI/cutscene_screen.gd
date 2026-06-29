extends CanvasLayer

# Cutscene Screen - By Ledouzy
# Handles cutscene playback


var cutscene_instance
var test # delete later


# plays a cutscene
func play_cutscene(cutscene_name: String):
	# if there is already a cutscene instantiated, it returns after printing an error message
	if cutscene_instance != null:
		print("ERROR: There is already a cutscene instantiated.")
		return
	# gets the cutscene
	var cutscene = load("res://scenes/cutscenes/"+cutscene_name+".tscn")
	if cutscene:
		# instantiate it
		cutscene_instance = cutscene.instantiate()
		self.add_child(cutscene_instance)
	# if not found print error
	else:
		print("Error: Cutscene \"", name, " \" does not exist.")
	
	# add code to get text for the cutscene
	

# ends the cutscene by removing the cutscene node
func end_cutscene():
	remove_child(cutscene_instance)
	cutscene_instance = null


func _process(delta: float) -> void:
	# debug code
	if Input.is_action_just_pressed("debug"):
		if !test:
			play_cutscene("himelia_reveal")
			test = true
		else:
			end_cutscene()
			test = false
	
