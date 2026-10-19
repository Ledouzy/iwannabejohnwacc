extends Node


# signal for displaying dialog
signal display_dialog(text_key: String)

# signal for ending dialog
signal end_dialog()

# signal for stopping the player when entering the grapple point area
signal stop_hookshot()
