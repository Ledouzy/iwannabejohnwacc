extends cutscene
@onready var sprite: TextureRect = $Sprite
@onready var background: TextureRect = $Background

func play():
	move_sprite(sprite, Vector2(0,0), 2, Tween.TRANS_QUAD , Tween.EASE_OUT)
	move_sprite(background, Vector2(0,0), 2, Tween.TRANS_QUAD , Tween.EASE_OUT)
	dialog_manager.display_dialog_on_bottom()
	await get_tree().create_timer(2).timeout
	SignalBus.emit_signal("display_dialog", dialog_key)
