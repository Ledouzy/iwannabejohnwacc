extends Node

# the interval that the fps will be printed
const TIMER_LIMIT = 2.0
# the timer that counts to 2
var timer = 0.0

func _process(delta):
	# add the time between frames to the timer
	timer += delta
	# if that time is greater than timer_limit, then reset timer and print fps
	if timer > TIMER_LIMIT: # Prints every 2 seconds
		timer = 0.0
		print("fps: " + str(Engine.get_frames_per_second()))
