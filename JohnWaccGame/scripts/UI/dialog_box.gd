extends Control

# self explanatory
@export var text_display_speed = 0.02

# if true, displays the entire text
var skip_text = false
# if true, you can go to the next line
var done = false

# list of all portraits and the coordinate they resdide at in the texture
var portrait_dict = {
	# jack portraits
	"jack_neutral": Vector2(0,0),
	"jack_serious": Vector2(32,0),
	"jack_happy": Vector2(64,0),
	"jack_surprised": Vector2(96,0),
	"jack_sad": Vector2(128,0),
	"jack_happy_closed": Vector2(160,0),
	"jack_thinking": Vector2(192,0),
	"jack_wink": Vector2(224,0),
	
	# princess portraits
	"princess_neutral": Vector2(0,32),
	"princess_happy": Vector2(32,32),
	"princess_sad": Vector2(64,32),
	"princess_surprised": Vector2(96,32),
	"princess_serious": Vector2(128,32),
	"princess_thinking": Vector2(160,32),
	"princess_sad_closed": Vector2(192,32),
	"princess_wink": Vector2(224,32),
	
	# princess portraits
	"lance_neutral": Vector2(0,64),
	"lance_serious": Vector2(32,64),
	"lance_sad": Vector2(64,64),
	"lance_happy": Vector2(96,64),
	"lance_surprised": Vector2(128,64),
	"lance_thinking": Vector2(160,64),
	"lance_happy_closed": Vector2(192,64),
	"lance_wink": Vector2(224,64),
	
	# christian portraits
	"christian_neutral": Vector2(0,96),
	"christian_serious": Vector2(32,96),
	"christian_happy": Vector2(64,96),
	"christian_surprised": Vector2(96,96),
	"christian_sad": Vector2(128,96),
	"christian_thinking": Vector2(160,96),
	"christian_sad_closed": Vector2(192,96),
	"christian_wink": Vector2(224,96),
	
	# john portraits
	"john_neutral": Vector2(0,128),
	"john_happy": Vector2(32,128),
	"john_serious": Vector2(64,128),
	"john_surprised": Vector2(96,128),
	"john_smirk": Vector2(128,128),
	"john_wink": Vector2(160,128),
	"john_thinking": Vector2(192,128),
	"john_car": Vector2(224,128),
	
	# misc portraits
	"car_neutral": Vector2(0,160),
	"car_blink": Vector2(32,160),
	"car_happy": Vector2(64,160),
	"king_car_neutral": Vector2(96,160),
	"king_car_blink": Vector2(128,160),
	"king_car_happy": Vector2(160,160),
	"unused1": Vector2(192,160),
	"unused2": Vector2(224,160),
	
	# Black Knight
	"knight_helmet": Vector2(0,192),
	"knight_neutral": Vector2(32,192),
	"knight_yell": Vector2(64,192),
	"knight_talk": Vector2(96,192),
	"knight_blink": Vector2(128,192),
	"unused3": Vector2(160,192),
	"unused4": Vector2(192,192),
	"unused5": Vector2(224,192),
	
	# Misc 2
	"bones_yell": Vector2(0,224),
	"bones_neutral": Vector2(32,224),
	"olmane_neutral": Vector2(64,224),
	"joof_left": Vector2(96,224),
	"joof_right": Vector2(128,224),
	"unused6": Vector2(160,224),
	"unused7": Vector2(192,224),
	"unused8": Vector2(224,224),
}

# the text layer
@onready var label: Label = $HBoxContainer/Label
# portrait
@onready var portrait: TextureRect = $HBoxContainer/Portrait


# returns the value of done
func is_done():
	return done


# changes skip text to true
func set_skip_text():
	skip_text = true


# displays text to the label
func display_text(text: String):
	# hide portrait
	portrait.visible = false
	
	# resets done back to false
	done = false
	# make the textbox empty
	label.text = ""
	
	# go over every character in the text we want to display
	for c in text:
		# if skip_text is true, then go out of the loop
		if skip_text:
			break
		# wait for a couple of milliseconds
		await get_tree().create_timer(text_display_speed).timeout
		# add the next character to the textbox
		label.text = label.text + c
	# when done, put the entirety of the text as the text of the textbox so that
	# when skipping dialogue it actually displays the entire text
	label.text = text
	
	# resets back skip_text to false
	skip_text = false
	# we are done
	done = true


# Displays text with a portrait
func display_text_portrait(text: String, portrait_name: String):
	# Call base function
	display_text(text)
	
	# if no portrait specified
	if portrait_name == null or portrait_name == "":
		return
	# show portrait
	portrait.visible = true
	
	# get the coordinates of the portrait we want to display
	var portrait_position: Vector2 = portrait_dict.get(portrait_name)
	
	# change the region of the texture to the coordinates we got
	portrait.texture.region = Rect2(portrait_position.x, portrait_position.y, 32.0, 32.0)


# set the textbox to visible
func toggle_on_dialog_box():
	self.visible = true


# set the textbox to invisible
func toggle_off_dialog_box():
	self.visible = false
