extends CanvasLayer

var cutscene_instance

var test # delete later

func play_cutscene(cutscene_name: String):
	if cutscene_instance != null:
		print("ERROR: There is already a cutscene instantiated.")
		return
	var cutscene = load("res://scenes/cutscenes/"+cutscene_name+".tscn")
	cutscene_instance = cutscene.instantiate()
	self.add_child(cutscene_instance)
	
	# add code to get text for the cutscene
	
func end_cutscene():
	remove_child(cutscene_instance)
	cutscene_instance = null
	
	
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug"):
		if !test:
			play_cutscene("himelia_reveal")
			test = true
		else:
			end_cutscene()
			test = false
	
