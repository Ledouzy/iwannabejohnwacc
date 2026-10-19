extends CanvasLayer

# Cutscene Screen - By Ledouzy
# Handles cutscene playback

@export var cutscene_name: String

var cutscene_instance

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
		cutscene_instance.play()
	# if not found print error
	else:
		print("Error: Cutscene \"", name, " \" does not exist.")
	
	# add code to get text for the cutscene
	

# ends the cutscene by removing the cutscene node
func end_cutscene():
	#remove_child(cutscene_instance)
	#cutscene_instance = null
	get_tree().paused = false
	scene_manager.load_next_scene()
	
func _ready():
	cutscene_name = global_manager.cutscene
	play_cutscene(cutscene_name)
	SignalBus.end_cutscene.connect(_on_end_cutscene)
	
func _on_end_cutscene():
	end_cutscene()
