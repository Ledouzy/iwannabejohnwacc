extends CharacterBody2D

# THIS IS BASICALLY A FIX SINCE GODOT IS CRINGE AND DOES NOT LET YOU SET COLLISION LAYER BY COLLISION SHAPE

# calls the take_damage function of it's parent
func take_damage(damage, direction):
	return get_parent().call_deferred("take_damage",damage, direction)
	
#func pickedUp(pickedby):
#	return get_parent().pickedUp(pickedby)
